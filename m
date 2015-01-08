From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/15] batman-adv: fix misspelled words
Date: Thu,  8 Jan 2015 16:15:18 +0100
Message-ID: <1420730120-9844-14-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27799 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbAHP3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:29:12 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: checkpatch
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bridge_loop_avoidance.c | 4 ++--
 net/batman-adv/main.c                  | 2 +-
 net/batman-adv/packet.h                | 4 ++--
 net/batman-adv/routing.c               | 2 +-
 net/batman-adv/translation-table.c     | 2 +-
 net/batman-adv/types.h                 | 2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 4fc6cab..ac4b96e 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -244,7 +244,7 @@ batadv_bla_del_backbone_claims(struct batadv_bla_backbone_gw *backbone_gw)
 		spin_unlock_bh(list_lock);
 	}
 
-	/* all claims gone, intialize CRC */
+	/* all claims gone, initialize CRC */
 	backbone_gw->crc = BATADV_BLA_CRC_INIT;
 }
 
@@ -1328,7 +1328,7 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 		goto out;
 	}
 	/* not found, add a new entry (overwrite the oldest entry)
-	 * and allow it, its the first occurence.
+	 * and allow it, its the first occurrence.
 	 */
 	curr = (bat_priv->bla.bcast_duplist_curr + BATADV_DUPLIST_SIZE - 1);
 	curr %= BATADV_DUPLIST_SIZE;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3bcd847..12fc77b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -798,7 +798,7 @@ void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_tvlv_realloc_packet_buff - reallocate packet buffer to accomodate
+ * batadv_tvlv_realloc_packet_buff - reallocate packet buffer to accommodate
  *  requested packet size
  * @packet_buff: packet buffer
  * @packet_buff_len: packet buffer size
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index facd1fe..b81fbbf 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -377,7 +377,7 @@ struct batadv_frag_packet {
 	uint8_t reserved:4;
 	uint8_t no:4;
 #else
-#error "unknown bitfield endianess"
+#error "unknown bitfield endianness"
 #endif
 	uint8_t dest[ETH_ALEN];
 	uint8_t orig[ETH_ALEN];
@@ -453,7 +453,7 @@ struct batadv_coded_packet {
  * @src: address of the source
  * @dst: address of the destination
  * @tvlv_len: length of tvlv data following the unicast tvlv header
- * @align: 2 bytes to align the header to a 4 byte boundry
+ * @align: 2 bytes to align the header to a 4 byte boundary
  */
 struct batadv_unicast_tvlv_packet {
 	uint8_t  packet_type;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 139d2f6..da83982 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -456,7 +456,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 	 * the last chosen bonding candidate (next_candidate). If no such
 	 * router is found, use the first candidate found (the previously
 	 * chosen bonding candidate might have been the last one in the list).
-	 * If this can't be found either, return the previously choosen
+	 * If this can't be found either, return the previously chosen
 	 * router - obviously there are no other candidates.
 	 */
 	rcu_read_lock();
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 84e6f01..07b263a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2852,7 +2852,7 @@ static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
 /**
  * batadv_is_my_client - check if a client is served by the local node
  * @bat_priv: the bat priv with all the soft interface information
- * @addr: the mac adress of the client to check
+ * @addr: the mac address of the client to check
  * @vid: VLAN identifier
  *
  * Returns true if the client is served by this node, false otherwise.
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 462a70c..9398c3f 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -968,7 +968,7 @@ struct batadv_tt_orig_list_entry {
 };
 
 /**
- * struct batadv_tt_change_node - structure for tt changes occured
+ * struct batadv_tt_change_node - structure for tt changes occurred
  * @list: list node for batadv_priv_tt::changes_list
  * @change: holds the actual translation table diff data
  */
-- 
2.2.1
