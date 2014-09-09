From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/2] ip/vxlan: fix display of maxaddress option
Date: Tue,  9 Sep 2014 16:55:11 +0200
Message-ID: <1410274511-17709-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1410274511-17709-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53429 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbaIIOzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 10:55:16 -0400
In-Reply-To: <1410274511-17709-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parenthesis are required else maxaddr value is a bool and thus output is always
1 when the option is set.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink_vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 8aa25cd5fe52..d92cfe8156e4 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -361,7 +361,7 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	}
 
 	if (tb[IFLA_VXLAN_LIMIT] &&
-	    (maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]) != 0))
+	    ((maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT])) != 0))
 		    fprintf(f, "maxaddr %u ", maxaddr);
 }
 
-- 
2.1.0
