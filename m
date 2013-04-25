From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH iproute2] iplink: add batadv interface type
Date: Thu, 25 Apr 2013 10:33:19 +0200
Message-ID: <1366878799-20237-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, Antonio Quartulli <ordex@autistici.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:29941 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab3DYIe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

batadv is another virtual interface type that can be created
via ip link. Add its name to the help screen.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index dc98019..2301cbc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,7 +84,7 @@ void iplink_usage(void)
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
-		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan }\n");
+		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan | batadv }\n");
 	}
 	exit(-1);
 }
-- 
1.8.1.5
