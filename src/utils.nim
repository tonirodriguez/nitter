import strutils, strformat, sequtils, uri, tables
import nimcrypto, regex

const
  key = "supersecretkey"
  twitterDomains = @[
    "twitter.com",
    "twimg.com",
    "abs.twimg.com",
    "pbs.twimg.com",
    "video.twimg.com"
  ]

proc mimetype*(filename: string): string =
  if ".png" in filename:
    "image/" & "png"
  elif ".jpg" in filename or ".jpeg" in filename or "1500x500" in filename:
    "image/" & "jpg"
  elif ".mp4" in filename:
    "video/" & "mp4"
  else:
    "text/plain"

proc getHmac*(data: string): string =
  ($hmac(sha256, key, data))[0 .. 12]

proc getVidUrl*(link: string): string =
  let
    sig = getHmac(link)
    url = encodeUrl(link)
  &"/video/{sig}/{url}"

proc getGifUrl*(link: string): string =
  &"/gif/{encodeUrl(link)}"

proc getPicUrl*(link: string): string =
  &"/pic/{encodeUrl(link)}"

proc cleanFilename*(filename: string): string =
  const reg = re"[^A-Za-z0-9._-]"
  filename.replace(reg, "_")

proc filterParams*(params: Table): seq[(string, string)] =
  let filter = ["name", "id"]
  toSeq(params.pairs()).filterIt(it[0] notin filter and it[1].len > 0)

proc isTwitterUrl*(url: string): bool =
  parseUri(url).hostname in twitterDomains
