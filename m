From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ipneigh: List all nud states in help output
Date: Fri,  4 Mar 2016 20:07:21 +0100
Message-ID: <1457118441-15349-3-git-send-email-phil@nwl.cc>
References: <1457118441-15349-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52089 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758710AbcCDTHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 14:07:40 -0500
In-Reply-To: <1457118441-15349-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To not make the output overly confusing, list them in a definition of
the STATE placeholder which is already used in the show/flush syntax but
wasn't explained before.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipneigh.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 9b1499b08b060..48cca196fa7a8 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -46,10 +46,11 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]\n"
-		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
-		        "          | proxy ADDR } [ dev DEV ]\n");
-	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "Usage: ip neigh { add | del | change | replace }\n"
+			"                { ADDR [ lladdr LLADDR ] [ nud STATE ] | proxy ADDR } [ dev DEV ]\n");
+	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n\n");
+	fprintf(stderr, "STATE := { permanent | noarp | stale | reachable | none |\n"
+	                "           incomplete | delay | probe | failed }\n");
 	exit(-1);
 }
 
-- 
2.7.2
