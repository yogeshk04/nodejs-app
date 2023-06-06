# syntax=docker/dockerfile:1

FROM node:18-alpine AS base

RUN apk add --update --no-cache \
    tzdata

FROM base as build

RUN echo create folder \
    && mkdir /src

# Set the working directory to /app
WORKDIR /src

# Stage 2: Build the application
ENV TZ=Europe/Berlin
ENV NODE_ENV="dev"

# For local build with .npmrc 
#COPY package.json package-lock.json tsconfig.json .npmrc /src/

COPY package.json package-lock.json tsconfig.json /src/

RUN \
    --mount=type=secret,id=npmrc,dst=/src/.npmrc \
    npm install

COPY . /src

# Build the application
RUN npm run server:build

# Stage 3: Create a lightweight production image
FROM base AS app

ENV NODE_ENV="prod"

WORKDIR /app

COPY --from=build /src/node_modules /app/node_modules
COPY --from=build /src/dist /app

ENV LOCAL_PORT=3000

EXPOSE 3000

CMD ["node", "/app/src/main.js"]

