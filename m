From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [patch iproute2] ipneigh: update ip neigh usage
Date: Fri, 29 Nov 2013 22:37:40 +0800
Message-ID: <1385735860-7574-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:60330 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab3K2Ohy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 09:37:54 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so14482195pbc.25
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 06:37:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From function nud_state_a2n we can see there are more states could be used. So
update the ip neigh usage.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ipneigh.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index d76e035..c203775 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -46,9 +46,12 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]\n"
-		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
-		        "          | proxy ADDR } [ dev DEV ]\n");
+		        "                    [ nud STATE ] | proxy ADDR } [ dev DEV ]\n");
+	fprintf(stderr, "\n");
 	fprintf(stderr, "       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "STATE := { permanent | reachable | noarp | none | stale |\n");
+	fprintf(stderr, "           incomplete | delay | probe | failed }\n");
 	exit(-1);
 }
 
-- 
1.8.1.4
