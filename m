From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 04/20] ipneigh: add missing proxy keyword to help text
Date: Wed,  2 Mar 2016 19:19:52 +0100
Message-ID: <1456942808-15946-5-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41073 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756322AbcCBSWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:22:01 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And while we're at it, add whitespace around braces and pipe symbol.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipneigh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 92b7cd6f2a75b..9b1499b08b060 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -49,7 +49,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]\n"
 		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
 		        "          | proxy ADDR } [ dev DEV ]\n");
-	fprintf(stderr, "       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
 	exit(-1);
 }
 
-- 
2.7.2
