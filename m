From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 1/3] iplink: add missing link type
Date: Wed, 12 Aug 2015 06:03:22 +0000
Message-ID: <1439359404-5085-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2370 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933635AbbHLGAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:00:23 -0400
In-Reply-To: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing link type "bridge_slave".

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index de5a3c9..7e5c466 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -93,7 +93,7 @@ void iplink_usage(void)
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
-		fprintf(stderr, "          bond_slave | ipvlan | geneve }\n");
+		fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave }\n");
 	}
 	exit(-1);
 }
-- 
1.8.3.1
