From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: improve filter help texts a bit
Date: Fri, 23 Oct 2015 19:21:17 +0200
Message-ID: <1445620877-5250-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44207 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbbJWRVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:21:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a few syntax errors and changes route filter help text to use
classid instead of flowid to be consistent with other filters' help
texts.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/f_flower.c | 4 ++--
 tc/f_route.c  | 2 +-
 tc/f_rsvp.c   | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 9a5ea06..a9b2c4d 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -28,7 +28,7 @@ static void explain(void)
 	fprintf(stderr, "                  [ action ACTION-SPEC ] [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: MATCH-LIST := [ MATCH-LIST ] MATCH\n");
-	fprintf(stderr, "       MATCH      := [ indev DEV-NAME | \n");
+	fprintf(stderr, "       MATCH      := { indev DEV-NAME | \n");
 	fprintf(stderr, "                       dst_mac MAC-ADDR | \n");
 	fprintf(stderr, "                       src_mac MAC-ADDR | \n");
 	fprintf(stderr, "                       eth_type [ipv4 | ipv6 | ETH-TYPE ] | \n");
@@ -36,7 +36,7 @@ static void explain(void)
 	fprintf(stderr, "                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] | \n");
 	fprintf(stderr, "                       src_ip [ IPV4-ADDR | IPV6-ADDR ] | \n");
 	fprintf(stderr, "                       dst_port PORT-NUMBER | \n");
-	fprintf(stderr, "                       src_port PORT-NUMBER | \n");
+	fprintf(stderr, "                       src_port PORT-NUMBER }\n");
 	fprintf(stderr,	"       FILTERID := X:Y:Z\n");
 	fprintf(stderr,	"       ACTION-SPEC := ... look at individual actions\n");
 	fprintf(stderr,	"\n");
diff --git a/tc/f_route.c b/tc/f_route.c
index 23c4ecc..4e9032c 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -28,7 +28,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... route [ from REALM | fromif TAG ] [ to REALM ]\n");
-	fprintf(stderr, "                [ flowid CLASSID ] [ action ACTION_SPEC ]]\n");
+	fprintf(stderr, "                [ classid CLASSID ] [ action ACTION_SPEC ]\n");
 	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "       CLASSID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index cb7b8fb..1fe9b15 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -27,7 +27,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... rsvp ipproto PROTOCOL session DST[/PORT | GPI ]\n");
-	fprintf(stderr, "                [ sender SRC[/PORT | GPI ]\n");
+	fprintf(stderr, "                [ sender SRC[/PORT | GPI ] ]\n");
 	fprintf(stderr, "                [ classid CLASSID ] [ action ACTION_SPEC ]\n");
 	fprintf(stderr, "                [ tunnelid ID ] [ tunnel ID skip NUMBER ]\n");
 	fprintf(stderr, "Where: GPI := { flowlabel NUMBER | spi/ah SPI | spi/esp SPI |\n");
-- 
2.1.2
