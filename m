From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 02/16] batman-adv: Remove kerneldoc for missing parameters
Date: Wed,  3 Feb 2016 10:18:23 +0800
Message-ID: <1454465917-13332-3-git-send-email-a__4712.17652452669$1454467281$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:11928 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932451AbcBCClM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:41:12 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/fragmentation.c     | 1 -
 net/batman-adv/packet.h            | 1 -
 net/batman-adv/routing.c           | 1 -
 net/batman-adv/translation-table.c | 4 ----
 4 files changed, 7 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 20d9282f895b..fedddbe0cd28 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -242,7 +242,6 @@ err:
 /**
  * batadv_frag_merge_packets - merge a chain of fragments
  * @chain: head of chain with fragments
- * @skb: packet with total size of skb after merging
  *
  * Expand the first skb in the chain and copy the content of the remaining
  * skb's into the expanded one. After doing so, clear the chain.
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index e80a8fc9f49e..6d5b17841ff5 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -413,7 +413,6 @@ struct batadv_bcast_packet {
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
- * @reserved: Align following fields to 2-byte boundaries
  * @first_source: original source of first included packet
  * @first_orig_dest: original destinal of first included packet
  * @first_crc: checksum of first included packet
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e4f2646d9246..54d660806c2a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -904,7 +904,6 @@ rx_success:
  * batadv_recv_unicast_tvlv - receive and process unicast tvlv packets
  * @skb: unicast tvlv packet to process
  * @recv_if: pointer to interface this packet was received on
- * @dst_addr: the payload destination
  *
  * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
  * otherwise.
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cdfc85fa2743..3ccede59c842 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -217,7 +217,6 @@ batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
 
 /**
  * batadv_tt_global_hash_count - count the number of orig entries
- * @hash: hash table containing the tt entries
  * @addr: the mac address of the client to count entries for
  * @vid: VLAN identifier
  *
@@ -288,7 +287,6 @@ static void batadv_tt_local_size_dec(struct batadv_priv *bat_priv,
 /**
  * batadv_tt_global_size_mod - change the size by v of the local table
  *  identified by vid
- * @bat_priv: the bat priv with all the soft interface information
  * @vid: the VLAN identifier
  * @v: the amount to sum to the global table size
  */
@@ -2406,7 +2404,6 @@ static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
  * @orig_node: originator for which the CRCs have to be checked
  * @tt_vlan: pointer to the first tvlv VLAN entry
  * @num_vlan: number of tvlv VLAN entries
- * @create: if true, create VLAN objects if not found
  *
  * Return true if all the received CRCs match the locally stored ones, false
  * otherwise
@@ -3375,7 +3372,6 @@ out:
  * @tt_change: pointer to the first entry in the TT buffer
  * @tt_num_changes: number of tt changes inside the tt buffer
  * @ttvn: translation table version number of this changeset
- * @tt_crc: crc32 checksum of orig node's translation table
  */
 static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 				  struct batadv_orig_node *orig_node,
-- 
2.7.0
