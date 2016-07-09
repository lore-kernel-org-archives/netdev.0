From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/6] iplink: List valid 'type' argument in ip link help text
Date: Sat,  9 Jul 2016 11:22:45 +0200
Message-ID: <1468056170-6056-2-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43158 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbcGIJXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:22 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index f2a2e13cf0c5b..0e3cee6af8b6f 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -55,7 +55,9 @@ void iplink_usage(void)
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
 		fprintf(stderr, "       ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]\n");
 		fprintf(stderr, "\n");
-		fprintf(stderr, "       ip link set { DEVICE | dev DEVICE | group DEVGROUP } [ { up | down } ]\n");
+		fprintf(stderr, "       ip link set { DEVICE | dev DEVICE | group DEVGROUP }\n");
+		fprintf(stderr, "	                  [ { up | down } ]\n");
+		fprintf(stderr, "	                  [ type TYPE ARGS ]\n");
 	} else
 		fprintf(stderr, "Usage: ip link set DEVICE [ { up | down } ]\n");
 
-- 
2.8.2
