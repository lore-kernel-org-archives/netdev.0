From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: pktgen: use reset to set mac header
Date: Mon, 29 Feb 2016 08:21:30 +0000
Message-ID: <1456734090-15366-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2872 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbcB2IUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 03:20:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/pktgen.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1474cfd..20999aa 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2856,7 +2856,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->len);
 	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
 
@@ -2983,7 +2983,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->len);
 	iph = (struct ipv6hdr *) skb_put(skb, sizeof(struct ipv6hdr));
 
-- 
1.8.3.1
