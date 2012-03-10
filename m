From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 4/4] batman-adv: Remove spaces after a cast
Date: Sun, 11 Mar 2012 06:44:51 +0800
Message-ID: <1331419491-21333-5-git-send-email-lindner_marek@yahoo.de>
References: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.240]:22637 "HELO
	nm9-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752522Ab2CJWqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 17:46:10 -0500
In-Reply-To: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/send.c    |    2 +-
 net/batman-adv/unicast.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f261ccf..af7a674 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -56,7 +56,7 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 
 	skb_reset_mac_header(skb);
 
-	ethhdr = (struct ethhdr *) skb_mac_header(skb);
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
 	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 0897dfa..676f6a6 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -66,7 +66,7 @@ static struct sk_buff *frag_merge_packet(struct list_head *head,
 	kfree_skb(tmp_skb);
 
 	memmove(skb->data + uni_diff, skb->data, hdr_len);
-	unicast_packet = (struct unicast_packet *) skb_pull(skb, uni_diff);
+	unicast_packet = (struct unicast_packet *)skb_pull(skb, uni_diff);
 	unicast_packet->header.packet_type = BAT_UNICAST;
 
 	return skb;
@@ -238,7 +238,7 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 		goto dropped;
 	skb_reserve(frag_skb, ucf_hdr_len);
 
-	unicast_packet = (struct unicast_packet *) skb->data;
+	unicast_packet = (struct unicast_packet *)skb->data;
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
 	skb_split(skb, frag_skb, data_len / 2 + uc_hdr_len);
 
-- 
1.7.9.1
