From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/16] batman-adv: Fix kerneldoc parsing of return description
Date: Wed,  3 Feb 2016 10:18:27 +0800
Message-ID: <1454465917-13332-7-git-send-email-a__12857.8923912302$1454467548$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:13513 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754827AbcBCCpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:45:13 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c            | 18 +++----
 net/batman-adv/bitarray.c              |  2 +-
 net/batman-adv/bitarray.h              | 11 +++--
 net/batman-adv/bridge_loop_avoidance.c | 68 ++++++++++++++++++--------
 net/batman-adv/distributed-arp-table.c | 37 +++++++-------
 net/batman-adv/fragmentation.c         | 17 ++++---
 net/batman-adv/fragmentation.h         |  2 +-
 net/batman-adv/gateway_client.c        | 14 +++---
 net/batman-adv/gateway_common.c        |  2 +-
 net/batman-adv/hard-interface.c        |  7 +--
 net/batman-adv/hash.h                  | 22 +++++----
 net/batman-adv/main.c                  | 26 +++++-----
 net/batman-adv/main.h                  | 13 +++--
 net/batman-adv/multicast.c             | 35 +++++++-------
 net/batman-adv/network-coding.c        | 42 ++++++++--------
 net/batman-adv/originator.c            | 48 +++++++++++--------
 net/batman-adv/routing.c               | 30 +++++++-----
 net/batman-adv/send.c                  | 24 +++++-----
 net/batman-adv/send.h                  |  4 +-
 net/batman-adv/soft-interface.c        | 14 +++---
 net/batman-adv/sysfs.c                 | 10 ++--
 net/batman-adv/translation-table.c     | 88 ++++++++++++++++++++--------------
 22 files changed, 305 insertions(+), 229 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index df625de55ef2..a6d389b0563c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -88,7 +88,7 @@ static void batadv_ring_buffer_set(u8 lq_recv[], u8 *lq_index, u8 value)
  * in the given ring buffer
  * @lq_recv: pointer to the ring buffer
  *
- * Returns computed average value.
+ * Return: computed average value.
  */
 static u8 batadv_ring_buffer_avg(const u8 lq_recv[])
 {
@@ -132,7 +132,7 @@ static void batadv_iv_ogm_orig_free(struct batadv_orig_node *orig_node)
  * @orig_node: the orig_node that has to be changed
  * @max_if_num: the current amount of interfaces
  *
- * Returns 0 on success, a negative error code otherwise.
+ * Return: 0 on success, a negative error code otherwise.
  */
 static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
 				     int max_if_num)
@@ -180,7 +180,7 @@ unlock:
  * @max_if_num: the current amount of interfaces
  * @del_if_num: the index of the interface being removed
  *
- * Returns 0 on success, a negative error code otherwise.
+ * Return: 0 on success, a negative error code otherwise.
  */
 static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
 				     int max_if_num, int del_if_num)
@@ -246,7 +246,7 @@ unlock:
  * @bat_priv: the bat priv with all the soft interface information
  * @addr: mac address of the originator
  *
- * Returns the originator object corresponding to the passed mac address or NULL
+ * Return: the originator object corresponding to the passed mac address or NULL
  * on failure.
  * If the object does not exists it is created an initialised.
  */
@@ -522,7 +522,7 @@ out:
  * @if_outgoing: interface for which the retransmission should be considered
  * @forw_packet: the forwarded packet which should be checked
  *
- * Returns true if new_packet can be aggregated with forw_packet
+ * Return: true if new_packet can be aggregated with forw_packet
  */
 static bool
 batadv_iv_ogm_can_aggregate(const struct batadv_ogm_packet *new_bat_ogm_packet,
@@ -1125,7 +1125,7 @@ out:
  * @if_incoming: interface where the packet was received
  * @if_outgoing: interface for which the retransmission should be considered
  *
- * Returns 1 if the link can be considered bidirectional, 0 otherwise
+ * Return: 1 if the link can be considered bidirectional, 0 otherwise
  */
 static int batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 				 struct batadv_orig_node *orig_neigh_node,
@@ -1269,7 +1269,7 @@ out:
  * @if_incoming: interface on which the OGM packet was received
  * @if_outgoing: interface for which the retransmission should be considered
  *
- * Returns duplicate status as enum batadv_dup_status
+ * Return: duplicate status as enum batadv_dup_status
  */
 static enum batadv_dup_status
 batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
@@ -1929,7 +1929,7 @@ static void batadv_iv_neigh_print(struct batadv_priv *bat_priv,
  * @neigh2: the second neighbor object of the comparison
  * @if_outgoing2: outgoing interface for the second neighbor
  *
- * Returns a value less, equal to or greater than 0 if the metric via neigh1 is
+ * Return: a value less, equal to or greater than 0 if the metric via neigh1 is
  * lower, the same as or higher than the metric via neigh2
  */
 static int batadv_iv_ogm_neigh_cmp(struct batadv_neigh_node *neigh1,
@@ -1970,7 +1970,7 @@ out:
  * @neigh2: the second neighbor object of the comparison
  * @if_outgoing2: outgoing interface for the second neighbor
  *
- * Returns true if the metric via neigh1 is equally good or better than
+ * Return: true if the metric via neigh1 is equally good or better than
  * the metric via neigh2, false otherwise.
  */
 static bool
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 25cbc36e997a..06bab5179bf9 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -31,7 +31,7 @@ static void batadv_bitmap_shift_left(unsigned long *seq_bits, s32 n)
 
 /* receive and process one packet within the sequence number window.
  *
- * returns:
+ * Return:
  *  1 if the window was moved (either new or very old)
  *  0 if the window was not moved/shifted.
  */
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 0226b220fe5b..cf2aeb0831a4 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -24,7 +24,10 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 
-/* Returns 1 if the corresponding bit in the given seq_bits indicates true
+/**
+ * batadv_test_bit
+ *
+ * Return: 1 if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno. Otherwise returns 0.
  */
 static inline int batadv_test_bit(const unsigned long *seq_bits,
@@ -48,8 +51,10 @@ static inline void batadv_set_bit(unsigned long *seq_bits, s32 n)
 	set_bit(n, seq_bits); /* turn the position on */
 }
 
-/* receive and process one packet, returns 1 if received seq_num is considered
- * new, 0 if old
+/**
+ * batadv_bit_get_packet - receive and process one packet
+ *
+ * Return: 1 if received seq_num is considered new, 0 if old
  */
 int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 			  int set_mark);
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index c24c481b666f..90c79948979c 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -58,7 +58,11 @@ static void
 batadv_bla_send_announce(struct batadv_priv *bat_priv,
 			 struct batadv_bla_backbone_gw *backbone_gw);
 
-/* return the index of the claim */
+/**
+ * batadv_choose_claim
+ *
+ * Return: the index of the claim
+ */
 static inline u32 batadv_choose_claim(const void *data, u32 size)
 {
 	struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
@@ -70,7 +74,11 @@ static inline u32 batadv_choose_claim(const void *data, u32 size)
 	return hash % size;
 }
 
-/* return the index of the backbone gateway */
+/**
+ * batadv_choose_backbone_gw
+ *
+ * Return: the index of the backbone gateway
+ */
 static inline u32 batadv_choose_backbone_gw(const void *data, u32 size)
 {
 	const struct batadv_bla_claim *claim = (struct batadv_bla_claim *)data;
@@ -145,8 +153,9 @@ static void batadv_claim_free_ref(struct batadv_bla_claim *claim)
  * @bat_priv: the bat priv with all the soft interface information
  * @data: search data (may be local/static data)
  *
- * looks for a claim in the hash, and returns it if found
- * or NULL otherwise.
+ * looks for a claim in the hash
+ *
+ * Return: claim if found or NULL otherwise.
  */
 static struct batadv_bla_claim
 *batadv_claim_hash_find(struct batadv_priv *bat_priv,
@@ -186,7 +195,7 @@ static struct batadv_bla_claim
  * @addr: the address of the originator
  * @vid: the VLAN ID
  *
- * Returns claim if found or NULL otherwise.
+ * Return: claim if found or NULL otherwise.
  */
 static struct batadv_bla_backbone_gw *
 batadv_backbone_hash_find(struct batadv_priv *bat_priv, u8 *addr,
@@ -666,7 +675,11 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 	batadv_claim_free_ref(claim);
 }
 
-/* check for ANNOUNCE frame, return 1 if handled */
+/**
+ * batadv_handle_announce - check for ANNOUNCE frame
+ *
+ * Return: 1 if handled
+ */
 static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 				  u8 *backbone_addr, unsigned short vid)
 {
@@ -716,7 +729,11 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 	return 1;
 }
 
-/* check for REQUEST frame, return 1 if handled */
+/**
+ * batadv_handle_request - check for REQUEST frame
+ *
+ * Return: 1 if handled
+ */
 static int batadv_handle_request(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
 				 u8 *backbone_addr, struct ethhdr *ethhdr,
@@ -740,7 +757,11 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
 	return 1;
 }
 
-/* check for UNCLAIM frame, return 1 if handled */
+/**
+ * batadv_handle_unclaim - check for UNCLAIM frame
+ *
+ * Return: 1 if handled
+ */
 static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
 				 u8 *backbone_addr, u8 *claim_addr,
@@ -769,7 +790,11 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 	return 1;
 }
 
-/* check for CLAIM frame, return 1 if handled */
+/**
+ * batadv_handle_claim - check for CLAIM frame
+ *
+ * Return: 1 if handled
+ */
 static int batadv_handle_claim(struct batadv_priv *bat_priv,
 			       struct batadv_hard_iface *primary_if,
 			       u8 *backbone_addr, u8 *claim_addr,
@@ -809,7 +834,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
  * This function also applies the group ID of the sender
  * if it is in the same mesh.
  *
- * returns:
+ * Return:
  *	2  - if it is a claim packet and on the same group
  *	1  - if is a claim packet from another group
  *	0  - if it is not a claim packet
@@ -880,7 +905,7 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
  *
  * Check if this is a claim frame, and process it accordingly.
  *
- * returns 1 if it was a claim frame, otherwise return 0 to
+ * Return: 1 if it was a claim frame, otherwise return 0 to
  * tell the callee that it can use the frame on its own.
  */
 static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
@@ -1397,7 +1422,7 @@ out:
  *
  * Check if the originator is a gateway for the VLAN identified by vid.
  *
- * Returns true if orig is a backbone for this vid, false otherwise.
+ * Return: true if orig is a backbone for this vid, false otherwise.
  */
 bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 				    unsigned short vid)
@@ -1436,9 +1461,10 @@ bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
  *
- * bla_is_backbone_gw inspects the skb for the VLAN ID and returns 1
- * if the orig_node is also a gateway on the soft interface, otherwise it
- * returns 0.
+ * bla_is_backbone_gw inspects the skb for the VLAN ID
+ *
+ * Return: 1 if the orig_node is also a gateway on the soft interface, otherwise
+ * it returns 0.
  */
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 			      struct batadv_orig_node *orig_node, int hdr_size)
@@ -1498,8 +1524,9 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
  *  * we have to race for a claim
  *  * if the frame is allowed on the LAN
  *
- * in these cases, the skb is further handled by this function and
- * returns 1, otherwise it returns 0 and the caller shall further
+ * in these cases, the skb is further handled by this function
+ *
+ * Return: 1 if handled, otherwise it returns 0 and the caller shall further
  * process the skb.
  */
 int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
@@ -1592,11 +1619,12 @@ out:
  *  * a claim was received which has to be processed
  *  * the frame is allowed on the mesh
  *
- * in these cases, the skb is further handled by this function and
- * returns 1, otherwise it returns 0 and the caller shall further
- * process the skb.
+ * in these cases, the skb is further handled by this function.
  *
  * This call might reallocate skb data.
+ *
+ * Return: 1 if handled, otherwise it returns 0 and the caller shall further
+ * process the skb.
  */
 int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		  unsigned short vid)
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index a49c705fb86b..2f13429ce5d3 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -76,7 +76,7 @@ static void batadv_dat_entry_free_ref(struct batadv_dat_entry *dat_entry)
  * batadv_dat_to_purge - check whether a dat_entry has to be purged or not
  * @dat_entry: the entry to check
  *
- * Returns true if the entry has to be purged now, false otherwise.
+ * Return: true if the entry has to be purged now, false otherwise.
  */
 static bool batadv_dat_to_purge(struct batadv_dat_entry *dat_entry)
 {
@@ -151,7 +151,7 @@ static void batadv_dat_purge(struct work_struct *work)
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Returns 1 if the two entries are the same, 0 otherwise.
+ * Return: 1 if the two entries are the same, 0 otherwise.
  */
 static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
 {
@@ -166,7 +166,7 @@ static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the hw_src field in the ARP packet.
+ * Return: the value of the hw_src field in the ARP packet.
  */
 static u8 *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
 {
@@ -183,7 +183,7 @@ static u8 *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the ip_src field in the ARP packet.
+ * Return: the value of the ip_src field in the ARP packet.
  */
 static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
 {
@@ -195,7 +195,7 @@ static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the hw_dst field in the ARP packet.
+ * Return: the value of the hw_dst field in the ARP packet.
  */
 static u8 *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
 {
@@ -207,7 +207,7 @@ static u8 *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the ip_dst field in the ARP packet.
+ * Return: the value of the ip_dst field in the ARP packet.
  */
 static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
 {
@@ -219,7 +219,7 @@ static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
  * @data: data to hash
  * @size: size of the hash table
  *
- * Returns the selected index in the hash table for the given data.
+ * Return: the selected index in the hash table for the given data.
  */
 static u32 batadv_hash_dat(const void *data, u32 size)
 {
@@ -256,7 +256,7 @@ static u32 batadv_hash_dat(const void *data, u32 size)
  * @ip: search key
  * @vid: VLAN identifier
  *
- * Returns the dat_entry if found, NULL otherwise.
+ * Return: the dat_entry if found, NULL otherwise.
  */
 static struct batadv_dat_entry *
 batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip,
@@ -440,7 +440,7 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
  * @candidate: orig_node under evaluation
  * @max_orig_node: last selected candidate
  *
- * Returns true if the node has been elected as next candidate or false
+ * Return: true if the node has been elected as next candidate or false
  * otherwise.
  */
 static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
@@ -558,7 +558,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
  * closest values (from the LEFT, with wrap around if needed) then the hash
  * value of the key. ip_dst is the key.
  *
- * Returns the candidate array of size BATADV_DAT_CANDIDATE_NUM.
+ * Return: the candidate array of size BATADV_DAT_CANDIDATE_NUM.
  */
 static struct batadv_dat_candidate *
 batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
@@ -602,7 +602,7 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
  * This function copies the skb with pskb_copy() and is sent as unicast packet
  * to each of the selected candidates.
  *
- * Returns true if the packet is sent to at least one candidate, false
+ * Return: true if the packet is sent to at least one candidate, false
  * otherwise.
  */
 static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
@@ -831,7 +831,7 @@ out:
  * @skb: packet to analyse
  * @hdr_size: size of the possible header before the ARP packet in the skb
  *
- * Returns the ARP type if the skb contains a valid ARP packet, 0 otherwise.
+ * Return: the ARP type if the skb contains a valid ARP packet, 0 otherwise.
  */
 static u16 batadv_arp_get_type(struct batadv_priv *bat_priv,
 			       struct sk_buff *skb, int hdr_size)
@@ -904,8 +904,9 @@ out:
  * @skb: the buffer containing the packet to extract the VID from
  * @hdr_size: the size of the batman-adv header encapsulating the packet
  *
- * If the packet embedded in the skb is vlan tagged this function returns the
- * VID with the BATADV_VLAN_HAS_TAG flag. Otherwise BATADV_NO_FLAGS is returned.
+ * Return: If the packet embedded in the skb is vlan tagged this function
+ * returns the VID with the BATADV_VLAN_HAS_TAG flag. Otherwise BATADV_NO_FLAGS
+ * is returned.
  */
 static unsigned short batadv_dat_get_vid(struct sk_buff *skb, int *hdr_size)
 {
@@ -930,7 +931,7 @@ static unsigned short batadv_dat_get_vid(struct sk_buff *skb, int *hdr_size)
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: packet to check
  *
- * Returns true if the message has been sent to the dht candidates, false
+ * Return: true if the message has been sent to the dht candidates, false
  * otherwise. In case of a positive return value the message has to be enqueued
  * to permit the fallback.
  */
@@ -1020,7 +1021,7 @@ out:
  * @skb: packet to check
  * @hdr_size: size of the encapsulation header
  *
- * Returns true if the request has been answered, false otherwise.
+ * Return: true if the request has been answered, false otherwise.
  */
 bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb, int hdr_size)
@@ -1143,7 +1144,7 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
  * @skb: packet to check
  * @hdr_size: size of the encapsulation header
  *
- * Returns true if the packet was snooped and consumed by DAT. False if the
+ * Return: true if the packet was snooped and consumed by DAT. False if the
  * packet has to be delivered to the interface
  */
 bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
@@ -1200,7 +1201,7 @@ out:
  * @bat_priv: the bat priv with all the soft interface information
  * @forw_packet: the broadcast packet
  *
- * Returns true if the node can drop the packet, false otherwise.
+ * Return: true if the node can drop the packet, false otherwise.
  */
 bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 				      struct batadv_forw_packet *forw_packet)
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index fedddbe0cd28..80eddf44a827 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -85,7 +85,7 @@ void batadv_frag_purge_orig(struct batadv_orig_node *orig_node,
 /**
  * batadv_frag_size_limit - maximum possible size of packet to be fragmented
  *
- * Returns the maximum size of payload that can be fragmented.
+ * Return: the maximum size of payload that can be fragmented.
  */
 static int batadv_frag_size_limit(void)
 {
@@ -107,7 +107,7 @@ static int batadv_frag_size_limit(void)
  *
  * Caller must hold chain->lock.
  *
- * Returns true if chain is empty and caller can just insert the new fragment
+ * Return: true if chain is empty and caller can just insert the new fragment
  * without searching for the right position.
  */
 static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
@@ -136,7 +136,7 @@ static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
  * Insert a new fragment into the reverse ordered chain in the right table
  * entry. The hash table entry is cleared if "old" fragments exist in it.
  *
- * Returns true if skb is buffered, false on error. If the chain has all the
+ * Return: true if skb is buffered, false on error. If the chain has all the
  * fragments needed to merge the packet, the chain is moved to the passed head
  * to avoid locking the chain in the table.
  */
@@ -246,7 +246,7 @@ err:
  * Expand the first skb in the chain and copy the content of the remaining
  * skb's into the expanded one. After doing so, clear the chain.
  *
- * Returns the merged skb or NULL on error.
+ * Return: the merged skb or NULL on error.
  */
 static struct sk_buff *
 batadv_frag_merge_packets(struct hlist_head *chain)
@@ -306,6 +306,9 @@ free:
  * There are three possible outcomes: 1) Packet is merged: Return true and
  * set *skb to merged packet; 2) Packet is buffered: Return true and set *skb
  * to NULL; 3) Error: Return false and leave skb as is.
+ *
+ * Return: true when packet is merged or buffered, false when skb is not not
+ * used.
  */
 bool batadv_frag_skb_buffer(struct sk_buff **skb,
 			    struct batadv_orig_node *orig_node_src)
@@ -343,7 +346,7 @@ out_err:
  * will exceed the MTU towards the next-hop. If so, the fragment is forwarded
  * without merging it.
  *
- * Returns true if the fragment is consumed/forwarded, false otherwise.
+ * Return: true if the fragment is consumed/forwarded, false otherwise.
  */
 bool batadv_frag_skb_fwd(struct sk_buff *skb,
 			 struct batadv_hard_iface *recv_if,
@@ -398,7 +401,7 @@ out:
  * passed mtu and the old one with the rest. The new skb contains data from the
  * tail of the old skb.
  *
- * Returns the new fragment, NULL on error.
+ * Return: the new fragment, NULL on error.
  */
 static struct sk_buff *batadv_frag_create(struct sk_buff *skb,
 					  struct batadv_frag_packet *frag_head,
@@ -432,7 +435,7 @@ err:
  * @orig_node: final destination of the created fragments
  * @neigh_node: next-hop of the created fragments
  *
- * Returns true on success, false otherwise.
+ * Return: true on success, false otherwise.
  */
 bool batadv_frag_send_packet(struct sk_buff *skb,
 			     struct batadv_orig_node *orig_node,
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index 8b9877e70b95..c5476fe79dc6 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -42,7 +42,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
  * batadv_frag_check_entry - check if a list of fragments has timed out
  * @frags_entry: table entry to check
  *
- * Returns true if the frags entry has timed out, false otherwise.
+ * Return: true if the frags entry has timed out, false otherwise.
  */
 static inline bool
 batadv_frag_check_entry(struct batadv_frag_table_entry *frags_entry)
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e6c8382c79ba..83507750bb66 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -456,7 +456,7 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: originator announcing gateway capabilities
  *
- * Returns gateway node if found or NULL otherwise.
+ * Return: gateway node if found or NULL otherwise.
  */
 static struct batadv_gw_node *
 batadv_gw_node_get(struct batadv_priv *bat_priv,
@@ -655,13 +655,13 @@ out:
  * @chaddr: buffer where the client address will be stored. Valid
  *  only if the function returns BATADV_DHCP_TO_CLIENT
  *
- * Returns:
+ * This function may re-allocate the data buffer of the skb passed as argument.
+ *
+ * Return:
  * - BATADV_DHCP_NO if the packet is not a dhcp message or if there was an error
  *   while parsing it
  * - BATADV_DHCP_TO_SERVER if this is a message going to the DHCP server
  * - BATADV_DHCP_TO_CLIENT if this is a message going to a DHCP client
- *
- * This function may re-allocate the data buffer of the skb passed as argument.
  */
 enum batadv_dhcp_recipient
 batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
@@ -776,11 +776,11 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
  * server. Due to topology changes it may be the case that the GW server
  * previously selected is not the best one anymore.
  *
- * Returns true if the packet destination is unicast and it is not the best gw,
- * false otherwise.
- *
  * This call might reallocate skb data.
  * Must be invoked only when the DHCP packet is going TO a DHCP SERVER.
+ *
+ * Return: true if the packet destination is unicast and it is not the best gw,
+ * false otherwise.
  */
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb)
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index b51bface8bdd..b287448b9921 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -38,7 +38,7 @@
  * @description: text shown when throughput string cannot be parsed
  * @throughput: pointer holding the returned throughput information
  *
- * Returns false on parse error and true otherwise.
+ * Return: false on parse error and true otherwise.
  */
 static bool batadv_parse_throughput(struct net_device *net_dev, char *buff,
 				    const char *description, u32 *throughput)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 01acccc4d218..49e05d238667 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -85,7 +85,7 @@ out:
  * This function recursively checks all the fathers of the device passed as
  * argument looking for a batman-adv soft interface.
  *
- * Returns true if the device is descendant of a batman-adv mesh interface (or
+ * Return: true if the device is descendant of a batman-adv mesh interface (or
  * if it is a batman-adv interface itself), false otherwise
  */
 static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
@@ -136,7 +136,7 @@ static int batadv_is_valid_iface(const struct net_device *net_dev)
  *  interface
  * @net_device: the device to check
  *
- * Returns true if the net device is a 802.11 wireless device, false otherwise.
+ * Return: true if the net device is a 802.11 wireless device, false otherwise.
  */
 bool batadv_is_wifi_netdev(struct net_device *net_device)
 {
@@ -401,7 +401,8 @@ batadv_hardif_deactivate_interface(struct batadv_hard_iface *hard_iface)
  *
  * Invoke ndo_del_slave on master passing slave as argument. In this way slave
  * is free'd and master can correctly change its internal state.
- * Return 0 on success, a negative value representing the error otherwise
+ *
+ * Return: 0 on success, a negative value representing the error otherwise
  */
 static int batadv_master_del_slave(struct batadv_hard_iface *slave,
 				   struct net_device *master)
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 377626250ac7..071a87ea4f2f 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -30,14 +30,17 @@
 struct lock_class_key;
 
 /* callback to a compare function.  should compare 2 element datas for their
- * keys, return 0 if same and not 0 if not same
+ * keys
+ *
+ * Return: 0 if same and not 0 if not same
  */
 typedef int (*batadv_hashdata_compare_cb)(const struct hlist_node *,
 					  const void *);
 
-/* the hashfunction, should return an index
- * based on the key in the data of the first
- * argument and the size the second
+/* the hashfunction
+ *
+ * Return: an index based on the key in the data of the first argument and the
+ * size the second
  */
 typedef u32 (*batadv_hashdata_choose_cb)(const void *, u32);
 typedef void (*batadv_hashdata_free_cb)(struct hlist_node *, void *);
@@ -96,7 +99,7 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
  *	@data: data passed to the aforementioned callbacks as argument
  *	@data_node: to be added element
  *
- *	Returns 0 on success, 1 if the element already is in the hash
+ *	Return: 0 on success, 1 if the element already is in the hash
  *	and -1 on error.
  */
 static inline int batadv_hash_add(struct batadv_hashtable *hash,
@@ -139,10 +142,11 @@ out:
 	return ret;
 }
 
-/* removes data from hash, if found. returns pointer do data on success, so you
- * can remove the used structure yourself, or NULL on error .  data could be the
- * structure you use with just the key filled, we just need the key for
- * comparing.
+/* removes data from hash, if found. data could be the structure you use with
+ * just the key filled, we just need the key for comparing.
+ *
+ * Return: returns pointer do data on success, so you can remove the used
+ * structure yourself, or NULL on error
  */
 static inline void *batadv_hash_remove(struct batadv_hashtable *hash,
 				       batadv_hashdata_compare_cb compare,
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 4b5d61fbadb1..70907f6f37ed 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -233,7 +233,7 @@ void batadv_mesh_free(struct net_device *soft_iface)
  * @bat_priv: the bat priv with all the soft interface information
  * @addr: the address to check
  *
- * Returns 'true' if the mac address was found, false otherwise.
+ * Return: 'true' if the mac address was found, false otherwise.
  */
 bool batadv_is_my_mac(struct batadv_priv *bat_priv, const u8 *addr)
 {
@@ -262,7 +262,7 @@ bool batadv_is_my_mac(struct batadv_priv *bat_priv, const u8 *addr)
  *  function that requires the primary interface
  * @seq: debugfs table seq_file struct
  *
- * Returns primary interface if found or NULL otherwise.
+ * Return: primary interface if found or NULL otherwise.
  */
 struct batadv_hard_iface *
 batadv_seq_print_text_primary_if_get(struct seq_file *seq)
@@ -297,7 +297,7 @@ out:
  * batadv_max_header_len - calculate maximum encapsulation overhead for a
  *  payload packet
  *
- * Return the maximum encapsulation overhead in bytes.
+ * Return: the maximum encapsulation overhead in bytes.
  */
 int batadv_max_header_len(void)
 {
@@ -640,7 +640,7 @@ batadv_tvlv_handler_free_ref(struct batadv_tvlv_handler *tvlv_handler)
  * @type: tvlv handler type to look for
  * @version: tvlv handler version to look for
  *
- * Returns tvlv handler if found or NULL otherwise.
+ * Return: tvlv handler if found or NULL otherwise.
  */
 static struct batadv_tvlv_handler
 *batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
@@ -688,7 +688,7 @@ static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container *tvlv)
  * Has to be called with the appropriate locks being acquired
  * (tvlv.container_list_lock).
  *
- * Returns tvlv container if found or NULL otherwise.
+ * Return: tvlv container if found or NULL otherwise.
  */
 static struct batadv_tvlv_container
 *batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
@@ -720,7 +720,7 @@ static struct batadv_tvlv_container
  * Has to be called with the appropriate locks being acquired
  * (tvlv.container_list_lock).
  *
- * Returns size of all currently registered tvlv containers in bytes.
+ * Return: size of all currently registered tvlv containers in bytes.
  */
 static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
 {
@@ -826,7 +826,7 @@ void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
  * @additional_packet_len: requested additional packet size on top of minimum
  *  size
  *
- * Returns true of the packet buffer could be changed to the requested size,
+ * Return: true of the packet buffer could be changed to the requested size,
  * false otherwise.
  */
 static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
@@ -862,7 +862,7 @@ static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
  * The ogm packet might be enlarged or shrunk depending on the current size
  * and the size of the to-be-appended tvlv containers.
  *
- * Returns size of all appended tvlv containers in bytes.
+ * Return: size of all appended tvlv containers in bytes.
  */
 u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
 				     unsigned char **packet_buff,
@@ -915,7 +915,7 @@ end:
  * @tvlv_value: tvlv content
  * @tvlv_value_len: tvlv content length
  *
- * Returns success if handler was not found or the return value of the handler
+ * Return: success if handler was not found or the return value of the handler
  * callback.
  */
 static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
@@ -968,7 +968,7 @@ static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
  * @tvlv_value: tvlv content
  * @tvlv_value_len: tvlv content length
  *
- * Returns success when processing an OGM or the return value of all called
+ * Return: success when processing an OGM or the return value of all called
  * handler callbacks.
  */
 int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
@@ -1190,8 +1190,8 @@ out:
  * @skb: the buffer containing the packet
  * @header_len: length of the batman header preceding the ethernet header
  *
- * If the packet embedded in the skb is vlan tagged this function returns the
- * VID with the BATADV_VLAN_HAS_TAG flag. Otherwise BATADV_NO_FLAGS is returned.
+ * Return: VID with the BATADV_VLAN_HAS_TAG flag when the packet embedded in the
+ * skb is vlan tagged. Otherwise BATADV_NO_FLAGS.
  */
 unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len)
 {
@@ -1218,7 +1218,7 @@ unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len)
  * @vid: the VLAN identifier for which the AP isolation attributed as to be
  *  looked up
  *
- * Returns true if AP isolation is on for the VLAN idenfied by vid, false
+ * Return: true if AP isolation is on for the VLAN idenfied by vid, false
  * otherwise
  */
 bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid)
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 9dbd9107e7e1..8a48d4a40828 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -273,9 +273,12 @@ static inline void _batadv_dbg(int type __always_unused,
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 
-/* returns 1 if they are the same ethernet addr
+/**
+ * batadv_compare_eth - Compare two not u16 aligned Ethernet addresses
  *
  * note: can't use ether_addr_equal() as it requires aligned memory
+ *
+ * Return: 1 if they are the same ethernet addr
  */
 static inline bool batadv_compare_eth(const void *data1, const void *data2)
 {
@@ -287,7 +290,7 @@ static inline bool batadv_compare_eth(const void *data1, const void *data2)
  * @timestamp:		base value to compare with (in jiffies)
  * @timeout:		added to base value before comparing (in milliseconds)
  *
- * Returns true if current time is after timestamp + timeout
+ * Return: true if current time is after timestamp + timeout
  */
 static inline bool batadv_has_timed_out(unsigned long timestamp,
 					unsigned int timeout)
@@ -326,7 +329,11 @@ static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
 
 #define batadv_inc_counter(b, i) batadv_add_counter(b, i, 1)
 
-/* Sum and return the cpu-local counters for index 'idx' */
+/**
+ * batadv_sum_counter - Sum the cpu-local counters for index 'idx'
+ *
+ * Return: sum of all cpu-local counters
+ */
 static inline u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
 {
 	u64 *counters, sum = 0;
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 75fa5013af72..d984eee1776c 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -55,7 +55,7 @@
  * Collect multicast addresses of the local multicast listeners
  * on the given soft interface, dev, in the given mcast_list.
  *
- * Returns -ENOMEM on memory allocation error or the number of
+ * Return: -ENOMEM on memory allocation error or the number of
  * items added to the mcast_list otherwise.
  */
 static int batadv_mcast_mla_softif_get(struct net_device *dev,
@@ -87,7 +87,7 @@ static int batadv_mcast_mla_softif_get(struct net_device *dev,
  * @mcast_addr: the multicast address to check
  * @mcast_list: the list with multicast addresses to search in
  *
- * Returns true if the given address is already in the given list.
+ * Return: true if the given address is already in the given list.
  * Otherwise returns false.
  */
 static bool batadv_mcast_mla_is_duplicate(u8 *mcast_addr,
@@ -195,8 +195,9 @@ static void batadv_mcast_mla_tt_add(struct batadv_priv *bat_priv,
  * batadv_mcast_has_bridge - check whether the soft-iface is bridged
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Checks whether there is a bridge on top of our soft interface. Returns
- * true if so, false otherwise.
+ * Checks whether there is a bridge on top of our soft interface.
+ *
+ * Return: true if there is a bridge, false otherwise.
  */
 static bool batadv_mcast_has_bridge(struct batadv_priv *bat_priv)
 {
@@ -218,7 +219,7 @@ static bool batadv_mcast_has_bridge(struct batadv_priv *bat_priv)
  * Updates the own multicast tvlv with our current multicast related settings,
  * capabilities and inabilities.
  *
- * Returns true if the tvlv container is registered afterwards. Otherwise
+ * Return: true if the tvlv container is registered afterwards. Otherwise
  * returns false.
  */
 static bool batadv_mcast_mla_tvlv_update(struct batadv_priv *bat_priv)
@@ -289,8 +290,8 @@ out:
  * Checks whether the given IPv4 packet has the potential to be forwarded with a
  * mode more optimal than classic flooding.
  *
- * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM in case of
- * memory allocation failure.
+ * Return: If so then 0. Otherwise -EINVAL or -ENOMEM in case of memory
+ * allocation failure.
  */
 static int batadv_mcast_forw_mode_check_ipv4(struct batadv_priv *bat_priv,
 					     struct sk_buff *skb,
@@ -327,8 +328,7 @@ static int batadv_mcast_forw_mode_check_ipv4(struct batadv_priv *bat_priv,
  * Checks whether the given IPv6 packet has the potential to be forwarded with a
  * mode more optimal than classic flooding.
  *
- * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM if we are out
- * of memory.
+ * Return: If so then 0. Otherwise -EINVAL is or -ENOMEM if we are out of memory
  */
 static int batadv_mcast_forw_mode_check_ipv6(struct batadv_priv *bat_priv,
 					     struct sk_buff *skb,
@@ -366,8 +366,7 @@ static int batadv_mcast_forw_mode_check_ipv6(struct batadv_priv *bat_priv,
  * Checks whether the given multicast ethernet frame has the potential to be
  * forwarded with a mode more optimal than classic flooding.
  *
- * If so then returns 0. Otherwise -EINVAL is returned or -ENOMEM if we are out
- * of memory.
+ * Return: If so then 0. Otherwise -EINVAL is or -ENOMEM if we are out of memory
  */
 static int batadv_mcast_forw_mode_check(struct batadv_priv *bat_priv,
 					struct sk_buff *skb,
@@ -398,7 +397,7 @@ static int batadv_mcast_forw_mode_check(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @ethhdr: ethernet header of a packet
  *
- * Returns the number of nodes which want all IPv4 multicast traffic if the
+ * Return: the number of nodes which want all IPv4 multicast traffic if the
  * given ethhdr is from an IPv4 packet or the number of nodes which want all
  * IPv6 traffic if it matches an IPv6 packet.
  */
@@ -421,7 +420,7 @@ static int batadv_mcast_forw_want_all_ip_count(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @ethhdr: the ether header containing the multicast destination
  *
- * Returns an orig_node matching the multicast address provided by ethhdr
+ * Return: an orig_node matching the multicast address provided by ethhdr
  * via a translation table lookup. This increases the returned nodes refcount.
  */
 static struct batadv_orig_node *
@@ -436,7 +435,7 @@ batadv_mcast_forw_tt_node_get(struct batadv_priv *bat_priv,
  * batadv_mcast_want_forw_ipv4_node_get - get a node with an ipv4 flag
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Returns an orig_node which has the BATADV_MCAST_WANT_ALL_IPV4 flag set and
+ * Return: an orig_node which has the BATADV_MCAST_WANT_ALL_IPV4 flag set and
  * increases its refcount.
  */
 static struct batadv_orig_node *
@@ -463,7 +462,7 @@ batadv_mcast_forw_ipv4_node_get(struct batadv_priv *bat_priv)
  * batadv_mcast_want_forw_ipv6_node_get - get a node with an ipv6 flag
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Returns an orig_node which has the BATADV_MCAST_WANT_ALL_IPV6 flag set
+ * Return: an orig_node which has the BATADV_MCAST_WANT_ALL_IPV6 flag set
  * and increases its refcount.
  */
 static struct batadv_orig_node *
@@ -491,7 +490,7 @@ batadv_mcast_forw_ipv6_node_get(struct batadv_priv *bat_priv)
  * @bat_priv: the bat priv with all the soft interface information
  * @ethhdr: an ethernet header to determine the protocol family from
  *
- * Returns an orig_node which has the BATADV_MCAST_WANT_ALL_IPV4 or
+ * Return: an orig_node which has the BATADV_MCAST_WANT_ALL_IPV4 or
  * BATADV_MCAST_WANT_ALL_IPV6 flag, depending on the provided ethhdr, set and
  * increases its refcount.
  */
@@ -514,7 +513,7 @@ batadv_mcast_forw_ip_node_get(struct batadv_priv *bat_priv,
  * batadv_mcast_want_forw_unsnoop_node_get - get a node with an unsnoopable flag
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Returns an orig_node which has the BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag
+ * Return: an orig_node which has the BATADV_MCAST_WANT_ALL_UNSNOOPABLES flag
  * set and increases its refcount.
  */
 static struct batadv_orig_node *
@@ -543,7 +542,7 @@ batadv_mcast_forw_unsnoop_node_get(struct batadv_priv *bat_priv)
  * @skb: The multicast packet to check
  * @orig: an originator to be set to forward the skb to
  *
- * Returns the forwarding mode as enum batadv_forw_mode and in case of
+ * Return: the forwarding mode as enum batadv_forw_mode and in case of
  * BATADV_FORW_SINGLE set the orig to the single originator the skb
  * should be forwarded to.
  */
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index cc63b44f0d2e..1a75d288f8a7 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -251,7 +251,7 @@ static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet)
  * @bat_priv: the bat priv with all the soft interface information
  * @nc_node: the nc node to check
  *
- * Returns true if the entry has to be purged now, false otherwise
+ * Return: true if the entry has to be purged now, false otherwise
  */
 static bool batadv_nc_to_purge_nc_node(struct batadv_priv *bat_priv,
 				       struct batadv_nc_node *nc_node)
@@ -267,7 +267,7 @@ static bool batadv_nc_to_purge_nc_node(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @nc_path: the nc path to check
  *
- * Returns true if the entry has to be purged now, false otherwise
+ * Return: true if the entry has to be purged now, false otherwise
  */
 static bool batadv_nc_to_purge_nc_path_coding(struct batadv_priv *bat_priv,
 					      struct batadv_nc_path *nc_path)
@@ -287,7 +287,7 @@ static bool batadv_nc_to_purge_nc_path_coding(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @nc_path: the nc path to check
  *
- * Returns true if the entry has to be purged now, false otherwise
+ * Return: true if the entry has to be purged now, false otherwise
  */
 static bool batadv_nc_to_purge_nc_path_decoding(struct batadv_priv *bat_priv,
 						struct batadv_nc_path *nc_path)
@@ -470,7 +470,7 @@ static void batadv_nc_hash_key_gen(struct batadv_nc_path *key, const char *src,
  * @data: data to hash
  * @size: size of the hash table
  *
- * Returns the selected index in the hash table for the given data.
+ * Return: the selected index in the hash table for the given data.
  */
 static u32 batadv_nc_hash_choose(const void *data, u32 size)
 {
@@ -489,7 +489,7 @@ static u32 batadv_nc_hash_choose(const void *data, u32 size)
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Returns 1 if the two entry are the same, 0 otherwise
+ * Return: 1 if the two entry are the same, 0 otherwise
  */
 static int batadv_nc_hash_compare(const struct hlist_node *node,
 				  const void *data2)
@@ -516,7 +516,7 @@ static int batadv_nc_hash_compare(const struct hlist_node *node,
  * @hash: hash table containing the nc path
  * @data: search key
  *
- * Returns the nc_path if found, NULL otherwise.
+ * Return: the nc_path if found, NULL otherwise.
  */
 static struct batadv_nc_path *
 batadv_nc_hash_find(struct batadv_hashtable *hash,
@@ -571,7 +571,7 @@ static void batadv_nc_send_packet(struct batadv_nc_packet *nc_packet)
  * timeout. If so, the packet is no longer kept and the entry deleted from the
  * queue. Has to be called with the appropriate locks.
  *
- * Returns false as soon as the entry in the fifo queue has not been timed out
+ * Return: false as soon as the entry in the fifo queue has not been timed out
  * yet and true otherwise.
  */
 static bool batadv_nc_sniffed_purge(struct batadv_priv *bat_priv,
@@ -610,7 +610,7 @@ out:
  * packet is no longer delayed, immediately sent and the entry deleted from the
  * queue. Has to be called with the appropriate locks.
  *
- * Returns false as soon as the entry in the fifo queue has not been timed out
+ * Return: false as soon as the entry in the fifo queue has not been timed out
  * yet and true otherwise.
  */
 static bool batadv_nc_fwd_flush(struct batadv_priv *bat_priv,
@@ -731,7 +731,7 @@ static void batadv_nc_worker(struct work_struct *work)
  * @orig_node: neighboring orig node which may be used as nc candidate
  * @ogm_packet: incoming ogm packet also used for the checks
  *
- * Returns true if:
+ * Return: true if:
  *  1) The OGM must have the most recent sequence number.
  *  2) The TTL must be decremented by one and only one.
  *  3) The OGM must be received from the first hop from orig_node.
@@ -772,7 +772,7 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
  *  (can be equal to orig_node)
  * @in_coding: traverse incoming or outgoing network coding list
  *
- * Returns the nc_node if found, NULL otherwise.
+ * Return: the nc_node if found, NULL otherwise.
  */
 static struct batadv_nc_node
 *batadv_nc_find_nc_node(struct batadv_orig_node *orig_node,
@@ -814,7 +814,7 @@ static struct batadv_nc_node
  *  (can be equal to orig_node)
  * @in_coding: traverse incoming or outgoing network coding list
  *
- * Returns the nc_node if found or created, NULL in case of an error.
+ * Return: the nc_node if found or created, NULL in case of an error.
  */
 static struct batadv_nc_node
 *batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
@@ -932,7 +932,7 @@ out:
  * @src: ethernet source address - first half of the nc path search key
  * @dst: ethernet destination address - second half of the nc path search key
  *
- * Returns pointer to nc_path if the path was found or created, returns NULL
+ * Return: pointer to nc_path if the path was found or created, returns NULL
  * on error.
  */
 static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
@@ -1029,7 +1029,7 @@ static void batadv_nc_memxor(char *dst, const char *src, unsigned int len)
  * @nc_packet: structure containing the packet to the skb can be coded with
  * @neigh_node: next hop to forward packet to
  *
- * Returns true if both packets are consumed, false otherwise.
+ * Return: true if both packets are consumed, false otherwise.
  */
 static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb,
@@ -1228,7 +1228,7 @@ out:
  * Since the source encoded the packet we can be certain it has all necessary
  * decode information.
  *
- * Returns true if coding of a decoded packet is allowed.
+ * Return: true if coding of a decoded packet is allowed.
  */
 static bool batadv_nc_skb_coding_possible(struct sk_buff *skb, u8 *dst, u8 *src)
 {
@@ -1246,7 +1246,7 @@ static bool batadv_nc_skb_coding_possible(struct sk_buff *skb, u8 *dst, u8 *src)
  * @skb: data skb to forward
  * @eth_dst: next hop mac address of skb
  *
- * Returns true if coding of a decoded skb is allowed.
+ * Return: true if coding of a decoded skb is allowed.
  */
 static struct batadv_nc_packet *
 batadv_nc_path_search(struct batadv_priv *bat_priv,
@@ -1314,7 +1314,7 @@ batadv_nc_path_search(struct batadv_priv *bat_priv,
  * @eth_src: source mac address of skb
  * @in_nc_node: pointer to skb next hop's neighbor nc node
  *
- * Returns an nc packet if a suitable coding packet was found, NULL otherwise.
+ * Return: an nc packet if a suitable coding packet was found, NULL otherwise.
  */
 static struct batadv_nc_packet *
 batadv_nc_skb_src_search(struct batadv_priv *bat_priv,
@@ -1397,7 +1397,7 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
  * next hop that potentially sent a packet which our next hop also received
  * (overheard) and has stored for later decoding.
  *
- * Returns true if the skb was consumed (encoded packet sent) or false otherwise
+ * Return: true if the skb was consumed (encoded packet sent) or false otherwise
  */
 static bool batadv_nc_skb_dst_search(struct sk_buff *skb,
 				     struct batadv_neigh_node *neigh_node,
@@ -1451,7 +1451,7 @@ static bool batadv_nc_skb_dst_search(struct sk_buff *skb,
  * @neigh_node: next hop to forward packet to
  * @packet_id: checksum to identify packet
  *
- * Returns true if the packet was buffered or false in case of an error.
+ * Return: true if the packet was buffered or false in case of an error.
  */
 static bool batadv_nc_skb_add_to_path(struct sk_buff *skb,
 				      struct batadv_nc_path *nc_path,
@@ -1485,7 +1485,7 @@ static bool batadv_nc_skb_add_to_path(struct sk_buff *skb,
  * @skb: data skb to forward
  * @neigh_node: next hop to forward packet to
  *
- * Returns true if the skb was consumed (encoded packet sent) or false otherwise
+ * Return: true if the skb was consumed (encoded packet sent) or false otherwise
  */
 bool batadv_nc_skb_forward(struct sk_buff *skb,
 			   struct batadv_neigh_node *neigh_node)
@@ -1624,7 +1624,7 @@ void batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
  * @skb: unicast skb to decode
  * @nc_packet: decode data needed to decode the skb
  *
- * Returns pointer to decoded unicast packet if the packet was decoded or NULL
+ * Return: pointer to decoded unicast packet if the packet was decoded or NULL
  * in case of an error.
  */
 static struct batadv_unicast_packet *
@@ -1718,7 +1718,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
  * @ethhdr: pointer to the ethernet header inside the coded packet
  * @coded: coded packet we try to find decode data for
  *
- * Returns pointer to nc packet if the needed data was found or NULL otherwise.
+ * Return: pointer to nc packet if the needed data was found or NULL otherwise.
  */
 static struct batadv_nc_packet *
 batadv_nc_find_decoding_packet(struct batadv_priv *bat_priv,
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index dfeebc89ed9a..ed1d6d7b717e 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -47,7 +47,11 @@ static struct lock_class_key batadv_orig_hash_lock_class_key;
 
 static void batadv_purge_orig(struct work_struct *work);
 
-/* returns 1 if they are the same originator */
+/**
+ * batadv_compare_orig
+ *
+ * Return: 1 if they are the same originator
+ */
 int batadv_compare_orig(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_orig_node,
@@ -61,7 +65,7 @@ int batadv_compare_orig(const struct hlist_node *node, const void *data2)
  * @orig_node: the originator serving the VLAN
  * @vid: the VLAN identifier
  *
- * Returns the vlan object identified by vid and belonging to orig_node or NULL
+ * Return: the vlan object identified by vid and belonging to orig_node or NULL
  * if it does not exist.
  */
 struct batadv_orig_node_vlan *
@@ -93,7 +97,7 @@ batadv_orig_node_vlan_get(struct batadv_orig_node *orig_node,
  * @orig_node: the originator serving the VLAN
  * @vid: the VLAN identifier
  *
- * Returns NULL in case of failure or the vlan object identified by vid and
+ * Return: NULL in case of failure or the vlan object identified by vid and
  * belonging to orig_node otherwise. The object is created and added to the list
  * if it does not exist.
  *
@@ -266,7 +270,7 @@ void batadv_neigh_node_free_ref(struct batadv_neigh_node *neigh_node)
  * @if_outgoing: the interface where the payload packet has been received or
  *  the OGM should be sent to
  *
- * Returns the neighbor which should be router for this orig_node/iface.
+ * Return: the neighbor which should be router for this orig_node/iface.
  *
  * The object is returned with refcounter increased by 1.
  */
@@ -298,7 +302,7 @@ batadv_orig_router_get(struct batadv_orig_node *orig_node,
  * @orig_node: the orig node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
  *
- * Returns the requested orig_ifinfo or NULL if not found.
+ * Return: the requested orig_ifinfo or NULL if not found.
  *
  * The object is returned with refcounter increased by 1.
  */
@@ -330,7 +334,7 @@ batadv_orig_ifinfo_get(struct batadv_orig_node *orig_node,
  * @orig_node: the orig node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
  *
- * Returns NULL in case of failure or the orig_ifinfo object for the if_outgoing
+ * Return: NULL in case of failure or the orig_ifinfo object for the if_outgoing
  * interface otherwise. The object is created and added to the list
  * if it does not exist.
  *
@@ -380,7 +384,7 @@ out:
  *
  * The object is returned with refcounter increased by 1.
  *
- * Returns the requested neigh_ifinfo or NULL if not found
+ * Return: the requested neigh_ifinfo or NULL if not found
  */
 struct batadv_neigh_ifinfo *
 batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
@@ -411,7 +415,7 @@ batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
  * @neigh: the neigh node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
  *
- * Returns NULL in case of failure or the neigh_ifinfo object for the
+ * Return: NULL in case of failure or the neigh_ifinfo object for the
  * if_outgoing interface otherwise. The object is created and added to the list
  * if it does not exist.
  *
@@ -459,7 +463,8 @@ out:
  *
  * Looks for and possibly returns a neighbour belonging to this originator list
  * which is connected through the provided hard interface.
- * Returns NULL if the neighbour is not found.
+ *
+ * Return: neighbor when found. Othwerwise NULL
  */
 static struct batadv_neigh_node *
 batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
@@ -492,7 +497,7 @@ batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
  * @hard_iface: the interface this neighbour is connected to
  * @neigh_addr: the interface address of the neighbour to retrieve
  *
- * Returns the hardif neighbour node if found or created or NULL otherwise.
+ * Return: the hardif neighbour node if found or created or NULL otherwise.
  */
 static struct batadv_hardif_neigh_node *
 batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
@@ -540,7 +545,7 @@ out:
  * @hard_iface: the interface this neighbour is connected to
  * @neigh_addr: the interface address of the neighbour to retrieve
  *
- * Returns the hardif neighbour node if found or created or NULL otherwise.
+ * Return: the hardif neighbour node if found or created or NULL otherwise.
  */
 static struct batadv_hardif_neigh_node *
 batadv_hardif_neigh_get_or_create(struct batadv_hard_iface *hard_iface,
@@ -562,7 +567,8 @@ batadv_hardif_neigh_get_or_create(struct batadv_hard_iface *hard_iface,
  * @neigh_addr: the address of the neighbour
  *
  * Looks for and possibly returns a neighbour belonging to this hard interface.
- * Returns NULL if the neighbour is not found.
+ *
+ * Return: neighbor when found. Othwerwise NULL
  */
 struct batadv_hardif_neigh_node *
 batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
@@ -594,7 +600,8 @@ batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
  * @neigh_addr: the mac address of the neighbour interface
  *
  * Allocates a new neigh_node object and initialises all the generic fields.
- * Returns the new object or NULL on failure.
+ *
+ * Return: neighbor when found. Othwerwise NULL
  */
 struct batadv_neigh_node *
 batadv_neigh_node_new(struct batadv_orig_node *orig_node,
@@ -656,7 +663,7 @@ out:
  * @seq: neighbour table seq_file struct
  * @offset: not used
  *
- * Always returns 0.
+ * Return: always 0
  */
 int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 {
@@ -820,7 +827,8 @@ void batadv_originator_free(struct batadv_priv *bat_priv)
  *
  * Creates a new originator object and initialise all the generic fields.
  * The new object is not added to the originator list.
- * Returns the newly created object or NULL on failure.
+ *
+ * Return: the newly created object or NULL on failure.
  */
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const u8 *addr)
@@ -937,7 +945,7 @@ batadv_purge_neigh_ifinfo(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node which is to be checked
  *
- * Returns true if any ifinfo entry was purged, false otherwise.
+ * Return: true if any ifinfo entry was purged, false otherwise.
  */
 static bool
 batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
@@ -989,7 +997,7 @@ batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node which is to be checked
  *
- * Returns true if any neighbor was purged, false otherwise
+ * Return: true if any neighbor was purged, false otherwise
  */
 static bool
 batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
@@ -1048,7 +1056,7 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
  * @orig_node: orig node which is to be checked
  * @if_outgoing: the interface for which the metric should be compared
  *
- * Returns the current best neighbor, with refcount increased.
+ * Return: the current best neighbor, with refcount increased.
  */
 static struct batadv_neigh_node *
 batadv_find_best_neighbor(struct batadv_priv *bat_priv,
@@ -1085,7 +1093,7 @@ batadv_find_best_neighbor(struct batadv_priv *bat_priv,
  * This function checks if the orig_node or substructures of it have become
  * obsolete, and purges this information if that's the case.
  *
- * Returns true if the orig_node is to be removed, false otherwise.
+ * Return: true if the orig_node is to be removed, false otherwise.
  */
 static bool batadv_purge_orig_node(struct batadv_priv *bat_priv,
 				   struct batadv_orig_node *orig_node)
@@ -1230,7 +1238,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
  * @seq: debugfs table seq_file struct
  * @offset: not used
  *
- * Returns 0
+ * Return: 0
  */
 int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset)
 {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 54d660806c2a..bcaa7870038b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -140,9 +140,12 @@ out:
 		batadv_neigh_node_free_ref(router);
 }
 
-/* checks whether the host restarted and is in the protection time.
- * returns:
- *  0 if the packet is to be accepted
+/**
+ * batadv_window_protected checks whether the host restarted and is in the
+ *  protection time.
+ *
+ * Return:
+ *  0 if the packet is to be accepted.
  *  1 if the packet is to be ignored.
  */
 int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
@@ -198,7 +201,7 @@ bool batadv_check_management_packet(struct sk_buff *skb,
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: icmp packet to process
  *
- * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * Return: NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
  * otherwise.
  */
 static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
@@ -398,10 +401,11 @@ out:
  * @skb: packet to check
  * @hdr_size: size of header to pull
  *
- * Check for short header and bad addresses in given packet. Returns negative
- * value when check fails and 0 otherwise. The negative value depends on the
- * reason: -ENODATA for bad header, -EBADR for broadcast destination or source,
- * and -EREMOTE for non-local (other host) destination.
+ * Check for short header and bad addresses in given packet.
+ *
+ * Return: negative value when check fails and 0 otherwise. The negative value
+ * depends on the reason: -ENODATA for bad header, -EBADR for broadcast
+ * destination or source, and -EREMOTE for non-local (other host) destination.
  */
 static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 				       struct sk_buff *skb, int hdr_size)
@@ -435,7 +439,7 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
  * @orig_node: the destination node
  * @recv_if: pointer to interface this packet was received on
  *
- * Returns the router which should be used for this orig_node on
+ * Return: the router which should be used for this orig_node on
  * this interface, or NULL if not available.
  */
 struct batadv_neigh_node *
@@ -648,7 +652,7 @@ out:
  * the new corresponding information (originator address where the destination
  * client currently is and its known TTVN)
  *
- * Returns true if the packet header has been updated, false otherwise
+ * Return: true if the packet header has been updated, false otherwise
  */
 static bool
 batadv_reroute_unicast_packet(struct batadv_priv *bat_priv,
@@ -805,7 +809,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
  * @skb: unicast tvlv packet to process
  * @recv_if: pointer to interface this packet was received on
  *
- * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * Return: NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
  * otherwise.
  */
 int batadv_recv_unhandled_unicast_packet(struct sk_buff *skb,
@@ -905,7 +909,7 @@ rx_success:
  * @skb: unicast tvlv packet to process
  * @recv_if: pointer to interface this packet was received on
  *
- * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * Return: NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
  * otherwise.
  */
 int batadv_recv_unicast_tvlv(struct sk_buff *skb,
@@ -959,7 +963,7 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb,
  * the assembled packet will exceed our MTU; 2) Buffer fragment, if we till
  * lack further fragments; 3) Merge fragments, if we have all needed parts.
  *
- * Return NET_RX_DROP if the skb is not consumed, NET_RX_SUCCESS otherwise.
+ * Return: NET_RX_DROP if the skb is not consumed, NET_RX_SUCCESS otherwise.
  */
 int batadv_recv_frag_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3fbf7910c4d1..d9b93c567bbc 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -111,7 +111,7 @@ send_skb_err:
  * host, NULL can be passed as recv_if and no interface alternating is
  * attempted.
  *
- * Returns NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
+ * Return: NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
  * NET_XMIT_POLICED if the skb is buffered for later transmit.
  */
 int batadv_send_skb_to_orig(struct sk_buff *skb,
@@ -165,7 +165,7 @@ out:
  * @hdr_size: amount of bytes to push at the beginning of the skb
  * @orig_node: the destination node
  *
- * Returns false if the buffer extension was not possible or true otherwise.
+ * Return: false if the buffer extension was not possible or true otherwise.
  */
 static bool
 batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
@@ -196,7 +196,7 @@ batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
  * @skb: the skb containing the payload to encapsulate
  * @orig_node: the destination node
  *
- * Returns false if the payload could not be encapsulated or true otherwise.
+ * Return: false if the payload could not be encapsulated or true otherwise.
  */
 static bool batadv_send_skb_prepare_unicast(struct sk_buff *skb,
 					    struct batadv_orig_node *orig_node)
@@ -214,7 +214,7 @@ static bool batadv_send_skb_prepare_unicast(struct sk_buff *skb,
  * @orig: the destination node
  * @packet_subtype: the unicast 4addr packet subtype to use
  *
- * Returns false if the payload could not be encapsulated or true otherwise.
+ * Return: false if the payload could not be encapsulated or true otherwise.
  */
 bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb,
@@ -265,7 +265,7 @@ out:
  * as packet_type. Then send this frame to the given orig_node and release a
  * reference to this orig_node.
  *
- * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
+ * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 			    struct sk_buff *skb, int packet_type,
@@ -339,7 +339,7 @@ out:
  * BATADV_UNICAST_4ADDR was supplied as packet_type. Then send this frame
  * to the according destination node.
  *
- * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
+ * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb, int packet_type,
@@ -373,7 +373,7 @@ int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
  * Look up the currently selected gateway. Wrap the given skb into a batman-adv
  * unicast header and send this frame to this gateway node.
  *
- * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
+ * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 			   unsigned short vid)
@@ -430,14 +430,16 @@ _batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 			   send_time);
 }
 
-/* add a broadcast packet to the queue and setup timers. broadcast packets
- * are sent multiple times to increase probability for being received.
+/**
+ * batadv_add_bcast_packet_to_list
  *
- * This function returns NETDEV_TX_OK on success and NETDEV_TX_BUSY on
- * errors.
+ * add a broadcast packet to the queue and setup timers. broadcast packets
+ * are sent multiple times to increase probability for being received.
  *
  * The skb is not consumed, so the caller should make sure that the
  * skb is freed.
+ *
+ * Return: NETDEV_TX_OK on success and NETDEV_TX_BUSY on errors.
  */
 int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 82059f259e46..3adc11fe1586 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -69,7 +69,7 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
  * header via the translation table. Wrap the given skb into a batman-adv
  * unicast header. Then send this frame to the according destination node.
  *
- * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
+ * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 static inline int batadv_send_skb_via_tt(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb, u8 *dst_hint,
@@ -92,7 +92,7 @@ static inline int batadv_send_skb_via_tt(struct batadv_priv *bat_priv,
  * unicast-4addr header. Then send this frame to the according destination
  * node.
  *
- * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
+ * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
 static inline int batadv_send_skb_via_tt_4addr(struct batadv_priv *bat_priv,
 					       struct sk_buff *skb,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c923e3c7b6ac..5ee794b62392 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -501,7 +501,7 @@ void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
  * @bat_priv: the bat priv with all the soft interface information
  * @vid: the identifier of the vlan object to retrieve
  *
- * Returns the private data of the vlan matching the vid passed as argument or
+ * Return: the private data of the vlan matching the vid passed as argument or
  * NULL otherwise. The refcounter of the returned object is incremented by 1.
  */
 struct batadv_softif_vlan *batadv_softif_vlan_get(struct batadv_priv *bat_priv,
@@ -530,7 +530,7 @@ struct batadv_softif_vlan *batadv_softif_vlan_get(struct batadv_priv *bat_priv,
  * @bat_priv: the bat priv with all the soft interface information
  * @vid: the VLAN identifier
  *
- * Returns 0 on success, a negative error otherwise.
+ * Return: 0 on success, a negative error otherwise.
  */
 int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 {
@@ -599,7 +599,7 @@ static void batadv_softif_destroy_vlan(struct batadv_priv *bat_priv,
  * Set up all the internal structures for handling the new vlan on top of the
  * mesh interface
  *
- * Returns 0 on success or a negative error code in case of failure.
+ * Return: 0 on success or a negative error code in case of failure.
  */
 static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
 				    unsigned short vid)
@@ -656,7 +656,7 @@ static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
  * Destroy all the internal structures used to handle the vlan identified by vid
  * on top of the mesh interface
  *
- * Returns 0 on success, -EINVAL if the specified prototype is not ETH_P_8021Q
+ * Return: 0 on success, -EINVAL if the specified prototype is not ETH_P_8021Q
  * or -ENOENT if the specified vlan id wasn't registered.
  */
 static int batadv_interface_kill_vid(struct net_device *dev, __be16 proto,
@@ -745,7 +745,7 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
  * batadv_softif_init_late - late stage initialization of soft interface
  * @dev: registered network device to modify
  *
- * Returns error code on failures
+ * Return: error code on failures
  */
 static int batadv_softif_init_late(struct net_device *dev)
 {
@@ -847,7 +847,7 @@ free_bat_counters:
  * @dev: batadv_soft_interface used as master interface
  * @slave_dev: net_device which should become the slave interface
  *
- * Return 0 if successful or error otherwise.
+ * Return: 0 if successful or error otherwise.
  */
 static int batadv_softif_slave_add(struct net_device *dev,
 				   struct net_device *slave_dev)
@@ -872,7 +872,7 @@ out:
  * @dev: batadv_soft_interface used as master interface
  * @slave_dev: net_device which should be removed from the master interface
  *
- * Return 0 if successful or error otherwise.
+ * Return: 0 if successful or error otherwise.
  */
 static int batadv_softif_slave_del(struct net_device *dev,
 				   struct net_device *slave_dev)
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 33772d9bd613..7658e6ea0596 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -64,7 +64,7 @@ static struct batadv_priv *batadv_kobj_to_batpriv(struct kobject *obj)
  * batadv_vlan_kobj_to_batpriv - convert a vlan kobj in the associated batpriv
  * @obj: kobject to covert
  *
- * Returns the associated batadv_priv struct.
+ * Return: the associated batadv_priv struct.
  */
 static struct batadv_priv *batadv_vlan_kobj_to_batpriv(struct kobject *obj)
 {
@@ -84,7 +84,7 @@ static struct batadv_priv *batadv_vlan_kobj_to_batpriv(struct kobject *obj)
  * batadv_kobj_to_vlan - convert a kobj in the associated softif_vlan struct
  * @obj: kobject to covert
  *
- * Returns the associated softif_vlan struct if found, NULL otherwise.
+ * Return: the associated softif_vlan struct if found, NULL otherwise.
  */
 static struct batadv_softif_vlan *
 batadv_kobj_to_vlan(struct batadv_priv *bat_priv, struct kobject *obj)
@@ -491,7 +491,7 @@ static ssize_t batadv_store_gw_bwidth(struct kobject *kobj,
  * @attr: the batman-adv attribute the user is interacting with
  * @buff: the buffer that will contain the data to send back to the user
  *
- * Returns the number of bytes written into 'buff' on success or a negative
+ * Return: the number of bytes written into 'buff' on success or a negative
  * error code in case of failure
  */
 static ssize_t batadv_show_isolation_mark(struct kobject *kobj,
@@ -511,7 +511,7 @@ static ssize_t batadv_show_isolation_mark(struct kobject *kobj,
  * @buff: the buffer containing the user data
  * @count: number of bytes in the buffer
  *
- * Returns 'count' on success or a negative error code in case of failure
+ * Return: 'count' on success or a negative error code in case of failure
  */
 static ssize_t batadv_store_isolation_mark(struct kobject *kobj,
 					   struct attribute *attr, char *buff,
@@ -681,7 +681,7 @@ void batadv_sysfs_del_meshif(struct net_device *dev)
  * @dev: netdev of the mesh interface
  * @vlan: private data of the newly added VLAN interface
  *
- * Returns 0 on success and -ENOMEM if any of the structure allocations fails.
+ * Return: 0 on success and -ENOMEM if any of the structure allocations fails.
  */
 int batadv_sysfs_add_vlan(struct net_device *dev,
 			  struct batadv_softif_vlan *vlan)
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7d8fc90c9e38..af1d24ce420f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -68,7 +68,11 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 				 unsigned short vid, const char *message,
 				 bool roaming);
 
-/* returns 1 if they are the same mac addr and vid */
+/**
+ * batadv_compare_tt
+ *
+ * Return: 1 if they are the same mac addr and vid
+ */
 static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 {
 	const void *data1 = container_of(node, struct batadv_tt_common_entry,
@@ -84,7 +88,7 @@ static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
  * @data: pointer to the tt_common_entry object to map
  * @size: the size of the hash table
  *
- * Returns the hash index where the object represented by 'data' should be
+ * Return: the hash index where the object represented by 'data' should be
  * stored at.
  */
 static inline u32 batadv_choose_tt(const void *data, u32 size)
@@ -105,7 +109,7 @@ static inline u32 batadv_choose_tt(const void *data, u32 size)
  * @addr: the mac address of the client to look for
  * @vid: VLAN identifier
  *
- * Returns a pointer to the tt_common struct belonging to the searched client if
+ * Return: a pointer to the tt_common struct belonging to the searched client if
  * found, NULL otherwise.
  */
 static struct batadv_tt_common_entry *
@@ -150,7 +154,7 @@ batadv_tt_hash_find(struct batadv_hashtable *hash, const u8 *addr,
  * @addr: the mac address of the client to look for
  * @vid: VLAN identifier
  *
- * Returns a pointer to the corresponding tt_local_entry struct if the client is
+ * Return: a pointer to the corresponding tt_local_entry struct if the client is
  * found, NULL otherwise.
  */
 static struct batadv_tt_local_entry *
@@ -175,7 +179,7 @@ batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const u8 *addr,
  * @addr: the mac address of the client to look for
  * @vid: VLAN identifier
  *
- * Returns a pointer to the corresponding tt_global_entry struct if the client
+ * Return: a pointer to the corresponding tt_global_entry struct if the client
  * is found, NULL otherwise.
  */
 static struct batadv_tt_global_entry *
@@ -220,7 +224,7 @@ batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
  * @addr: the mac address of the client to count entries for
  * @vid: VLAN identifier
  *
- * Return the number of originators advertising the given address/data
+ * Return: the number of originators advertising the given address/data
  * (excluding ourself).
  */
 int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
@@ -433,7 +437,7 @@ unlock:
  * batadv_tt_len - compute length in bytes of given number of tt changes
  * @changes_num: number of tt changes
  *
- * Returns computed length in bytes.
+ * Return: computed length in bytes.
  */
 static int batadv_tt_len(int changes_num)
 {
@@ -444,7 +448,7 @@ static int batadv_tt_len(int changes_num)
  * batadv_tt_entries - compute the number of entries fitting in tt_len bytes
  * @tt_len: available space
  *
- * Returns the number of entries.
+ * Return: the number of entries.
  */
 static u16 batadv_tt_entries(u16 tt_len)
 {
@@ -456,7 +460,7 @@ static u16 batadv_tt_entries(u16 tt_len)
  *  size when transmitted over the air
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Returns local translation table size in bytes.
+ * Return: local translation table size in bytes.
  */
 static int batadv_tt_local_table_transmit_size(struct batadv_priv *bat_priv)
 {
@@ -522,7 +526,7 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
  * @mark: the value contained in the skb->mark field of the received packet (if
  *  any)
  *
- * Returns true if the client was successfully added, false otherwise.
+ * Return: true if the client was successfully added, false otherwise.
  */
 bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 			 unsigned short vid, int ifindex, u32 mark)
@@ -722,7 +726,7 @@ out:
  * header made up by one tvlv_tt_data object and a series of tvlv_tt_vlan_data
  * objects, one per active VLAN served by the originator node.
  *
- * Return the size of the allocated buffer or 0 in case of failure.
+ * Return: the size of the allocated buffer or 0 in case of failure.
  */
 static u16
 batadv_tt_prepare_tvlv_global_data(struct batadv_orig_node *orig_node,
@@ -796,7 +800,7 @@ out:
  * header made up by one tvlv_tt_data object and a series of tvlv_tt_vlan_data
  * objects, one per active VLAN.
  *
- * Return the size of the allocated buffer or 0 in case of failure.
+ * Return: the size of the allocated buffer or 0 in case of failure.
  */
 static u16
 batadv_tt_prepare_tvlv_local_data(struct batadv_priv *bat_priv,
@@ -1038,7 +1042,7 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
  * @message: message to append to the log on deletion
  * @roaming: true if the deletion is due to a roaming event
  *
- * Returns the flags assigned to the local entry before being deleted
+ * Return: the flags assigned to the local entry before being deleted
  */
 u16 batadv_tt_local_remove(struct batadv_priv *bat_priv, const u8 *addr,
 			   unsigned short vid, const char *message,
@@ -1238,10 +1242,13 @@ static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt.changes_list_lock);
 }
 
-/* retrieves the orig_tt_list_entry belonging to orig_node from the
+/**
+ * batadv_tt_global_orig_entry_find
+ *
+ * retrieves the orig_tt_list_entry belonging to orig_node from the
  * batadv_tt_global_entry list
  *
- * returns it with an increased refcounter, NULL if not found
+ * Return: it with an increased refcounter, NULL if not found
  */
 static struct batadv_tt_orig_list_entry *
 batadv_tt_global_orig_entry_find(const struct batadv_tt_global_entry *entry,
@@ -1266,8 +1273,12 @@ batadv_tt_global_orig_entry_find(const struct batadv_tt_global_entry *entry,
 	return orig_entry;
 }
 
-/* find out if an orig_node is already in the list of a tt_global_entry.
- * returns true if found, false otherwise
+/**
+ * batadv_tt_global_entry_has_orig
+ *
+ * find out if an orig_node is already in the list of a tt_global_entry.
+ *
+ * Return: true if found, false otherwise
  */
 static bool
 batadv_tt_global_entry_has_orig(const struct batadv_tt_global_entry *entry,
@@ -1339,7 +1350,7 @@ out:
  *
  * The caller must hold orig_node refcount.
  *
- * Return true if the new entry has been added, false otherwise
+ * Return: true if the new entry has been added, false otherwise
  */
 static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 				 struct batadv_orig_node *orig_node,
@@ -1497,7 +1508,7 @@ out:
  * @tt_global_entry: global translation table entry to be analyzed
  *
  * This functon assumes the caller holds rcu_read_lock().
- * Returns best originator list entry or NULL on errors.
+ * Return: best originator list entry or NULL on errors.
  */
 static struct batadv_tt_orig_list_entry *
 batadv_transtable_best_orig(struct batadv_priv *bat_priv,
@@ -2027,7 +2038,7 @@ _batadv_is_ap_isolated(struct batadv_tt_local_entry *tt_local_entry,
  * @addr: mac address of the destination client
  * @vid: VLAN identifier
  *
- * Returns a pointer to the originator that was selected as destination in the
+ * Return: a pointer to the originator that was selected as destination in the
  * mesh for contacting the client 'addr', NULL otherwise.
  * In case of multiple originators serving the same client, the function returns
  * the best one (best in terms of metric towards the destination node).
@@ -2102,7 +2113,7 @@ out:
  * because the XOR operation can combine them all while trying to reduce the
  * noise as much as possible.
  *
- * Returns the checksum of the global table of a given originator.
+ * Return: the checksum of the global table of a given originator.
  */
 static u32 batadv_tt_global_crc(struct batadv_priv *bat_priv,
 				struct batadv_orig_node *orig_node,
@@ -2179,7 +2190,7 @@ static u32 batadv_tt_global_crc(struct batadv_priv *bat_priv,
  * For details about the computation, please refer to the documentation for
  * batadv_tt_global_crc().
  *
- * Returns the checksum of the local table
+ * Return: the checksum of the local table
  */
 static u32 batadv_tt_local_crc(struct batadv_priv *bat_priv,
 			       unsigned short vid)
@@ -2285,7 +2296,7 @@ static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node this request is being issued for
  *
- * Returns the pointer to the new tt_req_node struct if no request
+ * Return: the pointer to the new tt_req_node struct if no request
  * has already been issued for this orig_node, NULL otherwise.
  */
 static struct batadv_tt_req_node *
@@ -2320,7 +2331,7 @@ unlock:
  * @entry_ptr: to be checked local tt entry
  * @data_ptr: not used but definition required to satisfy the callback prototype
  *
- * Returns 1 if the entry is a valid, 0 otherwise.
+ * Return: 1 if the entry is a valid, 0 otherwise.
  */
 static int batadv_tt_local_valid(const void *entry_ptr, const void *data_ptr)
 {
@@ -2405,7 +2416,7 @@ static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
  * @tt_vlan: pointer to the first tvlv VLAN entry
  * @num_vlan: number of tvlv VLAN entries
  *
- * Return true if all the received CRCs match the locally stored ones, false
+ * Return: true if all the received CRCs match the locally stored ones, false
  * otherwise
  */
 static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
@@ -2588,7 +2599,7 @@ out:
  * @req_src: mac address of tt request sender
  * @req_dst: mac address of tt request recipient
  *
- * Returns true if tt request reply was sent, false otherwise.
+ * Return: true if tt request reply was sent, false otherwise.
  */
 static bool batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 					  struct batadv_tvlv_tt_data *tt_data,
@@ -2720,7 +2731,7 @@ out:
  * @tt_data: tt data containing the tt request information
  * @req_src: mac address of tt request sender
  *
- * Returns true if tt request reply was sent, false otherwise.
+ * Return: true if tt request reply was sent, false otherwise.
  */
 static bool batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 				       struct batadv_tvlv_tt_data *tt_data,
@@ -2838,7 +2849,7 @@ out:
  * @req_src: mac address of tt request sender
  * @req_dst: mac address of tt request recipient
  *
- * Returns true if tt request reply was sent, false otherwise.
+ * Return: true if tt request reply was sent, false otherwise.
  */
 static bool batadv_send_tt_response(struct batadv_priv *bat_priv,
 				    struct batadv_tvlv_tt_data *tt_data,
@@ -2933,7 +2944,7 @@ static void batadv_tt_update_changes(struct batadv_priv *bat_priv,
  * @addr: the mac address of the client to check
  * @vid: VLAN identifier
  *
- * Returns true if the client is served by this node, false otherwise.
+ * Return: true if the client is served by this node, false otherwise.
  */
 bool batadv_is_my_client(struct batadv_priv *bat_priv, const u8 *addr,
 			 unsigned short vid)
@@ -3050,11 +3061,14 @@ static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
 }
 
-/* This function checks whether the client already reached the
+/**
+ * batadv_tt_check_roam_count
+ *
+ * This function checks whether the client already reached the
  * maximum number of possible roaming phases. In this case the ROAMING_ADV
  * will not be sent.
  *
- * returns true if the ROAMING_ADV can be sent, false otherwise
+ * Return: true if the ROAMING_ADV can be sent, false otherwise
  */
 static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv, u8 *client)
 {
@@ -3453,7 +3467,7 @@ request_table:
  * @addr: the mac address of the client to check
  * @vid: VLAN identifier
  *
- * Returns true if we know that the client has moved from its old originator
+ * Return: true if we know that the client has moved from its old originator
  * to another one. This entry is still kept for consistency purposes and will be
  * deleted later by a DEL or because of timeout
  */
@@ -3479,7 +3493,7 @@ out:
  * @addr: the mac address of the local client to query
  * @vid: VLAN identifier
  *
- * Returns true if the local client is known to be roaming (it is not served by
+ * Return: true if the local client is known to be roaming (it is not served by
  * this node anymore) or not. If yes, the client is still present in the table
  * to keep the latter consistent with the node TTVN
  */
@@ -3608,7 +3622,7 @@ static void batadv_tt_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
  * @tvlv_value: tvlv buffer containing the tt data
  * @tvlv_value_len: tvlv buffer length
  *
- * Returns NET_RX_DROP if the tt tvlv is to be re-routed, NET_RX_SUCCESS
+ * Return: NET_RX_DROP if the tt tvlv is to be re-routed, NET_RX_SUCCESS
  * otherwise.
  */
 static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
@@ -3689,7 +3703,7 @@ static int batadv_tt_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
  * @tvlv_value: tvlv buffer containing the tt data
  * @tvlv_value_len: tvlv buffer length
  *
- * Returns NET_RX_DROP if the tt roam tvlv is to be re-routed, NET_RX_SUCCESS
+ * Return: NET_RX_DROP if the tt roam tvlv is to be re-routed, NET_RX_SUCCESS
  * otherwise.
  */
 static int batadv_roam_tvlv_unicast_handler_v1(struct batadv_priv *bat_priv,
@@ -3735,7 +3749,7 @@ out:
  * batadv_tt_init - initialise the translation table internals
  * @bat_priv: the bat priv with all the soft interface information
  *
- * Return 0 on success or negative error number in case of failure.
+ * Return: 0 on success or negative error number in case of failure.
  */
 int batadv_tt_init(struct batadv_priv *bat_priv)
 {
@@ -3773,7 +3787,7 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
  * @addr: the mac address of the client
  * @vid: the identifier of the VLAN where this client is connected
  *
- * Returns true if the client is marked with the TT_CLIENT_ISOLA flag, false
+ * Return: true if the client is marked with the TT_CLIENT_ISOLA flag, false
  * otherwise
  */
 bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
-- 
2.7.0
