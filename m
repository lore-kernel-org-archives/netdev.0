From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] iplink: update available type list
Date: Tue,  8 Oct 2013 16:59:38 +0200
Message-ID: <1381244378-26506-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53119 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3JHO7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 10:59:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvtap and vti were missing.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 16cb6fed9fcf..6cde731ac328 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,9 +84,9 @@ void iplink_usage(void)
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
-		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
-		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan |\n");
-		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap }\n");
+		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
+		fprintf(stderr, "          can | bridge | ipoib | ip6tnl | ipip | sit | vxlan |\n");
+		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
 	}
 	exit(-1);
 }
-- 
1.8.4.1
