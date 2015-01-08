From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/15] batman-adv: checkpatch - remove unnecessary parentheses
Date: Thu,  8 Jan 2015 16:15:16 +0100
Message-ID: <1420730120-9844-12-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23187 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864AbbAHPbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:31:53 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4dd7c40..00e00e0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -878,7 +878,7 @@ batadv_iv_ogm_slide_own_bcast_window(struct batadv_hard_iface *hard_iface)
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
 			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 			word_index = hard_iface->if_num * BATADV_NUM_WORDS;
-			word = &(orig_node->bat_iv.bcast_own[word_index]);
+			word = &orig_node->bat_iv.bcast_own[word_index];
 
 			batadv_bit_get_packet(bat_priv, word, 1, 0);
 			if_num = hard_iface->if_num;
@@ -1663,7 +1663,7 @@ static void batadv_iv_ogm_process(const struct sk_buff *skb, int ogm_offset,
 			offset = if_num * BATADV_NUM_WORDS;
 
 			spin_lock_bh(&orig_neigh_node->bat_iv.ogm_cnt_lock);
-			word = &(orig_neigh_node->bat_iv.bcast_own[offset]);
+			word = &orig_neigh_node->bat_iv.bcast_own[offset];
 			bit_pos = if_incoming_seqno - 2;
 			bit_pos -= ntohl(ogm_packet->seqno);
 			batadv_set_bit(word, bit_pos);
-- 
2.2.1
