From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH] batman-adv: use consistent kerneldoc style
Date: Thu, 16 Jan 2014 00:24:23 +0100
Message-ID: <1389828263-798-2-git-send-email-antonio@meshcoding.com>
References: <1389828263-798-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27409 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbaAOXZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:25:30 -0500
In-Reply-To: <1389828263-798-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Reported-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            |  6 ++++--
 net/batman-adv/bridge_loop_avoidance.c | 24 ++++++++++++++++++------
 net/batman-adv/translation-table.c     |  8 +++++---
 net/batman-adv/types.h                 |  6 ++++--
 4 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 921ac20..512159b 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -598,7 +598,8 @@ out:
 	return res;
 }
 
-/* batadv_iv_ogm_aggregate_new - create a new aggregated packet and add this
+/**
+ * batadv_iv_ogm_aggregate_new - create a new aggregated packet and add this
  *  packet to it.
  * @packet_buff: pointer to the OGM
  * @packet_len: (total) length of the OGM
@@ -1745,7 +1746,8 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	return NET_RX_SUCCESS;
 }
 
-/* batadv_iv_ogm_orig_print_neigh - print neighbors for the originator table
+/**
+ * batadv_iv_ogm_orig_print_neigh - print neighbors for the originator table
  * @orig_node: the orig_node for which the neighbors are printed
  * @if_outgoing: outgoing interface for these entries
  * @seq: debugfs table seq_file struct
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5c0eda4..05f0712 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -130,7 +130,9 @@ static void batadv_claim_free_ref(struct batadv_bla_claim *claim)
 		call_rcu(&claim->rcu, batadv_claim_free_rcu);
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_claim_hash_find
+ * @bat_priv: the bat priv with all the soft interface information
  * @data: search data (may be local/static data)
  *
  * looks for a claim in the hash, and returns it if found
@@ -449,7 +451,9 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
 	batadv_backbone_gw_free_ref(backbone_gw);
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_answer_request - answer a bla request by sending own claims
+ * @bat_priv: the bat priv with all the soft interface information
  * @vid: the vid where the request came on
  *
  * Repeat all of our own claims, and finally send an ANNOUNCE frame
@@ -495,7 +499,9 @@ static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
 	batadv_backbone_gw_free_ref(backbone_gw);
 }
 
-/* @backbone_gw: the backbone gateway from whom we are out of sync
+/**
+ * batadv_bla_send_request - send a request to repeat claims
+ * @backbone_gw: the backbone gateway from whom we are out of sync
  *
  * When the crc is wrong, ask the backbone gateway for a full table update.
  * After the request, it will repeat all of his own claims and finally
@@ -520,7 +526,9 @@ static void batadv_bla_send_request(struct batadv_bla_backbone_gw *backbone_gw)
 	}
 }
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_send_announce
+ * @bat_priv: the bat priv with all the soft interface information
  * @backbone_gw: our backbone gateway which should be announced
  *
  * This function sends an announcement. It is called from multiple
@@ -844,7 +852,9 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 }
 
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_process_claim
+ * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  *
  * Check if this is a claim frame, and process it accordingly.
@@ -1311,7 +1321,9 @@ out:
 
 
 
-/* @bat_priv: the bat priv with all the soft interface information
+/**
+ * batadv_bla_is_backbone_gw_orig
+ * @bat_priv: the bat priv with all the soft interface information
  * @orig: originator mac address
  * @vid: VLAN identifier
  *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a6fb1ff..b6071f6 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1382,7 +1382,8 @@ out:
 	return ret;
 }
 
-/* batadv_transtable_best_orig - Get best originator list entry from tt entry
+/**
+ * batadv_transtable_best_orig - Get best originator list entry from tt entry
  * @bat_priv: the bat priv with all the soft interface information
  * @tt_global_entry: global translation table entry to be analyzed
  *
@@ -1426,8 +1427,9 @@ batadv_transtable_best_orig(struct batadv_priv *bat_priv,
 	return best_entry;
 }
 
-/* batadv_tt_global_print_entry - print all orig nodes who announce the address
- * for this global entry
+/**
+ * batadv_tt_global_print_entry - print all orig nodes who announce the address
+ *  for this global entry
  * @bat_priv: the bat priv with all the soft interface information
  * @tt_global_entry: global translation table entry to be printed
  * @seq: debugfs table seq_file struct
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b53f90d..78370ab 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -333,7 +333,8 @@ struct batadv_neigh_node {
 	struct rcu_head rcu;
 };
 
-/* struct batadv_neigh_node_bat_iv - neighbor information per outgoing
+/**
+ * struct batadv_neigh_node_bat_iv - neighbor information per outgoing
  *  interface for BATMAN IV
  * @tq_recv: ring buffer of received TQ values from this neigh node
  * @tq_index: ring buffer index
@@ -350,7 +351,8 @@ struct batadv_neigh_ifinfo_bat_iv {
 	uint8_t real_packet_count;
 };
 
-/* struct batadv_neigh_ifinfo - neighbor information per outgoing interface
+/**
+ * struct batadv_neigh_ifinfo - neighbor information per outgoing interface
  * @list: list node for batadv_neigh_node::ifinfo_list
  * @if_outgoing: pointer to outgoing hard interface
  * @bat_iv: B.A.T.M.A.N. IV private structure
-- 
1.8.5.3
