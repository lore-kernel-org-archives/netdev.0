From: Richard Godbee <richard@godbee.net>
Subject: [PATCH] iproute2: iproute.c: fix usage() spacing problems
Date: Sun, 25 Aug 2013 22:19:11 -0400
Message-ID: <1377483553-23626-1-git-send-email-richard@godbee.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa06-04.prod.phx3.secureserver.net ([173.201.192.105]:52223
	"EHLO p3plsmtpa06-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195Ab3HZC1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 22:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix two spacing problems around square brackets in usage text.

Signed-off-by: Richard Godbee <richard@godbee.net>
---
 ip/iproute.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index b069f1e..25a56d1 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -63,7 +63,7 @@ static void usage(void)
 	fprintf(stderr, "       ip route restore\n");
 	fprintf(stderr, "       ip route showdump\n");
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
-	fprintf(stderr, "                            [ oif STRING ]  [ tos TOS ]\n");
+	fprintf(stderr, "                            [ oif STRING ] [ tos TOS ]\n");
 	fprintf(stderr, "                            [ mark NUMBER ]\n");
 	fprintf(stderr, "       ip route { add | del | change | append | replace } ROUTE\n");
 	fprintf(stderr, "SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]\n");
@@ -76,7 +76,7 @@ static void usage(void)
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
-	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [reordering NUMBER ]\n");
+	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
-- 
1.8.2.2
