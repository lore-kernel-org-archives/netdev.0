From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/16] batman-adv: use VLAN_ETH_HLEN instead of sizeof(struct vlan_eth_hdr)
Date: Sun, 13 Oct 2013 13:22:51 +0200
Message-ID: <1381663381-626-7-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:34779 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab3JMLYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:23 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 264de88..70da18a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1380,7 +1380,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)(((uint8_t *)skb->data) + hdr_size);
 
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
-		if (!pskb_may_pull(skb, hdr_size + sizeof(struct vlan_ethhdr)))
+		if (!pskb_may_pull(skb, hdr_size + VLAN_ETH_HLEN))
 			return 0;
 
 		vhdr = (struct vlan_ethhdr *)(skb->data + hdr_size);
-- 
1.8.3.2
