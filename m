From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/3] ip6tnl: fix sparse warnings in ip6_tnl_netlink_parms()
Date: Thu, 15 Nov 2012 09:53:36 +0100
Message-ID: <1352969616-30476-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35926 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756022Ab2KOIy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:54:57 -0500
In-Reply-To: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ab4d056..bf3a549 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1568,7 +1568,7 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 		parms->encap_limit = nla_get_u8(data[IFLA_IPTUN_ENCAP_LIMIT]);
 
 	if (data[IFLA_IPTUN_FLOWINFO])
-		parms->flowinfo = nla_get_u32(data[IFLA_IPTUN_FLOWINFO]);
+		parms->flowinfo = nla_get_be32(data[IFLA_IPTUN_FLOWINFO]);
 
 	if (data[IFLA_IPTUN_FLAGS])
 		parms->flags = nla_get_u32(data[IFLA_IPTUN_FLAGS]);
-- 
1.7.12
