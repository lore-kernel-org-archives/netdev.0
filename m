From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/3] ipip: fix sparse warnings in ipip_netlink_parms()
Date: Thu, 15 Nov 2012 09:53:34 +0100
Message-ID: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35920 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab2KOIyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:54:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 64686e1..c26c171 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -864,10 +864,10 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
+		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL]) {
 		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
-- 
1.7.12
