From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/16] batman-adv: Fix kerneldoc parsing of structs/enums
Date: Wed,  3 Feb 2016 10:18:22 +0800
Message-ID: <1454465917-13332-2-git-send-email-a__7274.56598910994$1454467288$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:6834 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932577AbcBCClI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:41:08 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/multicast.h | 2 +-
 net/batman-adv/packet.h    | 8 ++++----
 net/batman-adv/types.h     | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 8f3cb04b9f13..685219f3fec9 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -23,7 +23,7 @@
 struct sk_buff;
 
 /**
- * batadv_forw_mode - the way a packet should be forwarded as
+ * enum batadv_forw_mode - the way a packet should be forwarded as
  * @BATADV_FORW_ALL: forward the packet to all nodes (currently via classic
  *  flooding)
  * @BATADV_FORW_SINGLE: forward the packet to a single node (currently via the
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 0558e3237e0e..e80a8fc9f49e 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -158,7 +158,7 @@ enum batadv_tt_client_flags {
 };
 
 /**
- * batadv_vlan_flags - flags for the four MSB of any vlan ID field
+ * enum batadv_vlan_flags - flags for the four MSB of any vlan ID field
  * @BATADV_VLAN_HAS_TAG: whether the field contains a valid vlan tag or not
  */
 enum batadv_vlan_flags {
@@ -230,7 +230,7 @@ struct batadv_ogm_packet {
 #define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
 
 /**
- * batadv_icmp_header - common members among all the ICMP packets
+ * struct batadv_icmp_header - common members among all the ICMP packets
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
@@ -256,7 +256,7 @@ struct batadv_icmp_header {
 };
 
 /**
- * batadv_icmp_packet - ICMP packet
+ * struct batadv_icmp_packet - ICMP packet
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
@@ -282,7 +282,7 @@ struct batadv_icmp_packet {
 #define BATADV_RR_LEN 16
 
 /**
- * batadv_icmp_packet_rr - ICMP RouteRecord packet
+ * struct batadv_icmp_packet_rr - ICMP RouteRecord packet
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 3437b667a2cd..8c3dda36d9ec 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -346,7 +346,7 @@ struct batadv_gw_node {
 };
 
 /**
- * batadv_hardif_neigh_node - unique neighbor per hard interface
+ * struct batadv_hardif_neigh_node - unique neighbor per hard interface
  * @list: list node for batadv_hard_iface::neigh_list
  * @addr: the MAC address of the neighboring interface
  * @if_incoming: pointer to incoming hard interface
-- 
2.7.0
