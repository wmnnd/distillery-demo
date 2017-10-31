#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:latest

#Copy the source folder into the Docker image
COPY . .

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    mix deps.get && \
    mix release

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="clock" && \
    ARCHIVE="`ls -d _build/prod/rel/$APP_NAME/releases/*/`$APP_NAME.tar.gz" && \
    mkdir /rel && \
    tar -xf $ARCHIVE -C /rel


#================
#Deployment Stage
#================
FROM pentacent/erlang-base-alpine:latest
ARG APP_NAME

#Set environment variables
ENV REPLACE_OS_VARS=true

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=0 /rel/ .

#Change user
USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/clock"]
CMD ["foreground"]
