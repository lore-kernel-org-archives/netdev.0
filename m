From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 14/16] batman-adv: Fix kerneldoc member names in for main structs
Date: Sat,  9 Jan 2016 21:20:19 +0800
Message-ID: <1452345621-15908-15-git-send-email-a__11905.214112676$1452346746$gmane$org@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:28657 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbcAINiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:38:54 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/types.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 876ac336c61e..d93501edb987 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -223,12 +223,12 @@ struct batadv_orig_bat_iv {
  * @orig: originator ethernet address
  * @ifinfo_list: list for routers per outgoing interface
  * @last_bonding_candidate: pointer to last ifinfo of last used router
- * @batadv_dat_addr_t:  address of the orig node in the distributed hash
+ * @dat_addr: address of the orig node in the distributed hash
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @mcast_handler_lock: synchronizes mcast-capability and -flag changes
  * @mcast_flags: multicast flags announced by the orig node
- * @mcast_want_all_unsnoop_node: a list node for the
+ * @mcast_want_all_unsnoopables_node: a list node for the
  *  mcast.want_all_unsnoopables list
  * @mcast_want_all_ipv4_node: a list node for the mcast.want_all_ipv4 list
  * @mcast_want_all_ipv6_node: a list node for the mcast.want_all_ipv6 list
@@ -427,7 +427,7 @@ struct batadv_neigh_ifinfo {
 
 /**
  * struct batadv_bcast_duplist_entry - structure for LAN broadcast suppression
- * @orig[ETH_ALEN]: mac address of orig node orginating the broadcast
+ * @orig: mac address of orig node orginating the broadcast
  * @crc: crc32 checksum of broadcast payload
  * @entrytime: time when the broadcast packet was received
  */
@@ -576,7 +576,7 @@ struct batadv_priv_tt {
 
 /**
  * struct batadv_priv_bla - per mesh interface bridge loope avoidance data
- * @num_requests; number of bla requests in flight
+ * @num_requests: number of bla requests in flight
  * @claim_hash: hash table containing mesh nodes this host has claimed
  * @backbone_hash: hash table containing all detected backbone gateways
  * @bcast_duplist: recently received broadcast packets array (for broadcast
@@ -799,7 +799,7 @@ struct batadv_softif_vlan {
  * @dat: distributed arp table data
  * @mcast: multicast data
  * @network_coding: bool indicating whether network coding is enabled
- * @batadv_priv_nc: network coding data
+ * @nc: network coding data
  */
 struct batadv_priv {
 	atomic_t mesh_state;
@@ -934,7 +934,7 @@ struct batadv_bla_backbone_gw {
  * struct batadv_bla_claim - claimed non-mesh client structure
  * @addr: mac address of claimed non-mesh client
  * @vid: vlan id this client was detected on
- * @batadv_bla_backbone_gw: pointer to backbone gw claiming this client
+ * @backbone_gw: pointer to backbone gw claiming this client
  * @lasttime: last time we heard of claim (locals only)
  * @hash_entry: hlist node for batadv_priv_bla::claim_hash
  * @refcount: number of contexts the object is used
-- 
2.7.0
