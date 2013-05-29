From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/21] batman-adv: fix typos in kernel doc & comments
Date: Wed, 29 May 2013 02:59:28 +0200
Message-ID: <1369789186-3600-4-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43826 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933320Ab3E2BBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:47 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 82 ++++++++++++++++------------------
 1 file changed, 39 insertions(+), 43 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 2399920..06345d4 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -45,9 +45,9 @@ static void batadv_dat_start_timer(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_dat_entry_free_ref - decrements the dat_entry refcounter and possibly
+ * batadv_dat_entry_free_ref - decrement the dat_entry refcounter and possibly
  * free it
- * @dat_entry: the oentry to free
+ * @dat_entry: the entry to free
  */
 static void batadv_dat_entry_free_ref(struct batadv_dat_entry *dat_entry)
 {
@@ -56,10 +56,10 @@ static void batadv_dat_entry_free_ref(struct batadv_dat_entry *dat_entry)
 }
 
 /**
- * batadv_dat_to_purge - checks whether a dat_entry has to be purged or not
+ * batadv_dat_to_purge - check whether a dat_entry has to be purged or not
  * @dat_entry: the entry to check
  *
- * Returns true if the entry has to be purged now, false otherwise
+ * Returns true if the entry has to be purged now, false otherwise.
  */
 static bool batadv_dat_to_purge(struct batadv_dat_entry *dat_entry)
 {
@@ -75,8 +75,8 @@ static bool batadv_dat_to_purge(struct batadv_dat_entry *dat_entry)
  *	      returns a boolean value: true is the entry has to be deleted,
  *	      false otherwise
  *
- * Loops over each entry in the DAT local storage and delete it if and only if
- * the to_purge function passed as argument returns true
+ * Loops over each entry in the DAT local storage and deletes it if and only if
+ * the to_purge function passed as argument returns true.
  */
 static void __batadv_dat_purge(struct batadv_priv *bat_priv,
 			       bool (*to_purge)(struct batadv_dat_entry *))
@@ -97,7 +97,7 @@ static void __batadv_dat_purge(struct batadv_priv *bat_priv,
 		spin_lock_bh(list_lock);
 		hlist_for_each_entry_safe(dat_entry, node_tmp, head,
 					  hash_entry) {
-			/* if an helper function has been passed as parameter,
+			/* if a helper function has been passed as parameter,
 			 * ask it if the entry has to be purged or not
 			 */
 			if (to_purge && !to_purge(dat_entry))
@@ -134,7 +134,7 @@ static void batadv_dat_purge(struct work_struct *work)
  * @node: node in the local table
  * @data2: second object to compare the node to
  *
- * Returns 1 if the two entry are the same, 0 otherwise
+ * Returns 1 if the two entries are the same, 0 otherwise.
  */
 static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
 {
@@ -149,7 +149,7 @@ static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the hw_src field in the ARP packet
+ * Returns the value of the hw_src field in the ARP packet.
  */
 static uint8_t *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
 {
@@ -166,7 +166,7 @@ static uint8_t *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the ip_src field in the ARP packet
+ * Returns the value of the ip_src field in the ARP packet.
  */
 static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
 {
@@ -178,7 +178,7 @@ static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the hw_dst field in the ARP packet
+ * Returns the value of the hw_dst field in the ARP packet.
  */
 static uint8_t *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
 {
@@ -190,7 +190,7 @@ static uint8_t *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
  * @skb: ARP packet
  * @hdr_size: size of the possible header before the ARP packet
  *
- * Returns the value of the ip_dst field in the ARP packet
+ * Returns the value of the ip_dst field in the ARP packet.
  */
 static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
 {
@@ -202,7 +202,7 @@ static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
  * @data: data to hash
  * @size: size of the hash table
  *
- * Returns the selected index in the hash table for the given data
+ * Returns the selected index in the hash table for the given data.
  */
 static uint32_t batadv_hash_dat(const void *data, uint32_t size)
 {
@@ -224,12 +224,12 @@ static uint32_t batadv_hash_dat(const void *data, uint32_t size)
 }
 
 /**
- * batadv_dat_entry_hash_find - looks for a given dat_entry in the local hash
+ * batadv_dat_entry_hash_find - look for a given dat_entry in the local hash
  * table
  * @bat_priv: the bat priv with all the soft interface information
  * @ip: search key
  *
- * Returns the dat_entry if found, NULL otherwise
+ * Returns the dat_entry if found, NULL otherwise.
  */
 static struct batadv_dat_entry *
 batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip)
@@ -343,9 +343,6 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	if (hdr_size == 0)
 		return;
 
-	/* if the ARP packet is encapsulated in a batman packet, let's print
-	 * some debug messages
-	 */
 	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
 
 	switch (unicast_4addr_packet->u.header.packet_type) {
@@ -409,7 +406,8 @@ static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
  * @candidate: orig_node under evaluation
  * @max_orig_node: last selected candidate
  *
- * Returns true if the node has been elected as next candidate or false othrwise
+ * Returns true if the node has been elected as next candidate or false
+ * otherwise.
  */
 static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
 					 int select, batadv_dat_addr_t tmp_max,
@@ -472,7 +470,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
 	 */
 	cands[select].type = BATADV_DAT_CANDIDATE_NOT_FOUND;
 
-	/* iterate over the originator list and find the node with closest
+	/* iterate over the originator list and find the node with the closest
 	 * dat_address which has not been selected yet
 	 */
 	for (i = 0; i < hash->size; i++) {
@@ -480,7 +478,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			/* the dht space is a ring and addresses are unsigned */
+			/* the dht space is a ring using unsigned addresses */
 			tmp_max = BATADV_DAT_ADDR_MAX - orig_node->dat_addr +
 				  ip_key;
 
@@ -512,7 +510,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_dat_select_candidates - selects the nodes which the DHT message has to
+ * batadv_dat_select_candidates - select the nodes which the DHT message has to
  * be sent to
  * @bat_priv: the bat priv with all the soft interface information
  * @ip_dst: ipv4 to look up in the DHT
@@ -521,7 +519,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
  * closest values (from the LEFT, with wrap around if needed) then the hash
  * value of the key. ip_dst is the key.
  *
- * Returns the candidate array of size BATADV_DAT_CANDIDATE_NUM
+ * Returns the candidate array of size BATADV_DAT_CANDIDATE_NUM.
  */
 static struct batadv_dat_candidate *
 batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
@@ -558,10 +556,11 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
  * @ip: the DHT key
  * @packet_subtype: unicast4addr packet subtype to use
  *
- * In this function the skb is copied by means of pskb_copy() and is sent as
- * unicast packet to each of the selected candidates
+ * This function copies the skb with pskb_copy() and is sent as unicast packet
+ * to each of the selected candidates.
  *
- * Returns true if the packet is sent to at least one candidate, false otherwise
+ * Returns true if the packet is sent to at least one candidate, false
+ * otherwise.
  */
 static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 				 struct sk_buff *skb, __be32 ip,
@@ -727,7 +726,7 @@ out:
  * @skb: packet to analyse
  * @hdr_size: size of the possible header before the ARP packet in the skb
  *
- * Returns the ARP type if the skb contains a valid ARP packet, 0 otherwise
+ * Returns the ARP type if the skb contains a valid ARP packet, 0 otherwise.
  */
 static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
 				    struct sk_buff *skb, int hdr_size)
@@ -754,9 +753,7 @@ static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
 
 	arphdr = (struct arphdr *)(skb->data + hdr_size + ETH_HLEN);
 
-	/* Check whether the ARP packet carries a valid
-	 * IP information
-	 */
+	/* check whether the ARP packet carries a valid IP information */
 	if (arphdr->ar_hrd != htons(ARPHRD_ETHER))
 		goto out;
 
@@ -784,7 +781,7 @@ static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
 	if (is_zero_ether_addr(hw_src) || is_multicast_ether_addr(hw_src))
 		goto out;
 
-	/* we don't care about the destination MAC address in ARP requests */
+	/* don't care about the destination MAC address in ARP requests */
 	if (arphdr->ar_op != htons(ARPOP_REQUEST)) {
 		hw_dst = batadv_arp_hw_dst(skb, hdr_size);
 		if (is_zero_ether_addr(hw_dst) ||
@@ -804,8 +801,8 @@ out:
  * @skb: packet to check
  *
  * Returns true if the message has been sent to the dht candidates, false
- * otherwise. In case of true the message has to be enqueued to permit the
- * fallback
+ * otherwise. In case of a positive return value the message has to be enqueued
+ * to permit the fallback.
  */
 bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb)
@@ -867,7 +864,7 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 		batadv_dbg(BATADV_DBG_DAT, bat_priv, "ARP request replied locally\n");
 		ret = true;
 	} else {
-		/* Send the request on the DHT */
+		/* Send the request to the DHT */
 		ret = batadv_dat_send_data(bat_priv, skb, ip_dst,
 					   BATADV_P_DAT_DHT_GET);
 	}
@@ -884,7 +881,7 @@ out:
  * @skb: packet to check
  * @hdr_size: size of the encapsulation header
  *
- * Returns true if the request has been answered, false otherwise
+ * Returns true if the request has been answered, false otherwise.
  */
 bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 					   struct sk_buff *skb, int hdr_size)
@@ -924,10 +921,9 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	if (!skb_new)
 		goto out;
 
-	/* to preserve backwards compatibility, here the node has to answer
-	 * using the same packet type it received for the request. This is due
-	 * to that if a node is not using the 4addr packet format it may not
-	 * support it.
+	/* To preserve backwards compatibility, the node has choose the outgoing
+	 * format based on the incoming request packet type. The assumption is
+	 * that a node not using the 4addr packet format doesn't support it.
 	 */
 	if (hdr_size == sizeof(struct batadv_unicast_4addr_packet))
 		err = batadv_unicast_4addr_send_skb(bat_priv, skb_new,
@@ -977,7 +973,7 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst);
 
 	/* Send the ARP reply to the candidates for both the IP addresses that
-	 * the node got within the ARP reply
+	 * the node obtained from the ARP reply
 	 */
 	batadv_dat_send_data(bat_priv, skb, ip_src, BATADV_P_DAT_DHT_PUT);
 	batadv_dat_send_data(bat_priv, skb, ip_dst, BATADV_P_DAT_DHT_PUT);
@@ -987,7 +983,7 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
  * DAT storage only
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: packet to check
- * @hdr_size: siaze of the encapsulation header
+ * @hdr_size: size of the encapsulation header
  */
 bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb, int hdr_size)
@@ -1031,11 +1027,11 @@ out:
 
 /**
  * batadv_dat_drop_broadcast_packet - check if an ARP request has to be dropped
- * (because the node has already got the reply via DAT) or not
+ * (because the node has already obtained the reply via DAT) or not
  * @bat_priv: the bat priv with all the soft interface information
  * @forw_packet: the broadcast packet
  *
- * Returns true if the node can drop the packet, false otherwise
+ * Returns true if the node can drop the packet, false otherwise.
  */
 bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 				      struct batadv_forw_packet *forw_packet)
-- 
1.8.1.5
