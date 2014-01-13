From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/14] batman-adv: remove returns at the end of void functions
Date: Mon, 13 Jan 2014 23:31:33 +0100
Message-ID: <1389652298-472-10-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:42243 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAMWeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:34:05 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return at the end of void functions is not needed.

Since most of the void functions in the code do not do so,
make all the others consistent by removing the useless
returns. Actually all the functions to be "fixed" are in
network-coding.h only.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/network-coding.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index ab59b3d..136db6d 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -62,7 +62,6 @@ static inline int batadv_nc_mesh_init(struct batadv_priv *bat_priv)
 
 static inline void batadv_nc_mesh_free(struct batadv_priv *bat_priv)
 {
-	return;
 }
 
 static inline void
@@ -72,7 +71,6 @@ batadv_nc_update_nc_node(struct batadv_priv *bat_priv,
 			 struct batadv_ogm_packet *ogm_packet,
 			 int is_single_hop_neigh)
 {
-	return;
 }
 
 static inline void
@@ -81,17 +79,14 @@ batadv_nc_purge_orig(struct batadv_priv *bat_priv,
 		     bool (*to_purge)(struct batadv_priv *,
 				      struct batadv_nc_node *))
 {
-	return;
 }
 
 static inline void batadv_nc_init_bat_priv(struct batadv_priv *bat_priv)
 {
-	return;
 }
 
 static inline void batadv_nc_init_orig(struct batadv_orig_node *orig_node)
 {
-	return;
 }
 
 static inline bool batadv_nc_skb_forward(struct sk_buff *skb,
@@ -104,14 +99,12 @@ static inline void
 batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
 				 struct sk_buff *skb)
 {
-	return;
 }
 
 static inline void
 batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
 				    struct sk_buff *skb)
 {
-	return;
 }
 
 static inline int batadv_nc_nodes_seq_print_text(struct seq_file *seq,
-- 
1.8.5.2
