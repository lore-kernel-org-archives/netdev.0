From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 08/16] batman-adv: Fix kerneldoc of network-coding functions
Date: Wed,  3 Feb 2016 10:18:29 +0800
Message-ID: <1454465917-13332-9-git-send-email-a__22684.9198261791$1454467267$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:4853 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932451AbcBCCk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:58 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/network-coding.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 1a75d288f8a7..3a752bea55fa 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -64,6 +64,8 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 
 /**
  * batadv_nc_init - one-time initialization for network coding
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 int __init batadv_nc_init(void)
 {
@@ -142,6 +144,8 @@ static void batadv_nc_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 /**
  * batadv_nc_mesh_init - initialise coding hash table and start house keeping
  * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 int batadv_nc_mesh_init(struct batadv_priv *bat_priv)
 {
@@ -989,6 +993,8 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
  * batadv_nc_random_weight_tq - scale the receivers TQ-value to avoid unfair
  *  selection of a receiver with slightly lower TQ than the other
  * @tq: to be weighted tq value
+ *
+ * Return: scaled tq value
  */
 static u8 batadv_nc_random_weight_tq(u8 tq)
 {
@@ -1781,6 +1787,9 @@ batadv_nc_find_decoding_packet(struct batadv_priv *bat_priv,
  *  resulting unicast packet
  * @skb: incoming coded packet
  * @recv_if: pointer to interface this packet was received on
+ *
+ * Return: NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * otherwise.
  */
 static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if)
@@ -1865,6 +1874,8 @@ void batadv_nc_mesh_free(struct batadv_priv *bat_priv)
  * batadv_nc_nodes_seq_print_text - print the nc node information
  * @seq: seq file to print on
  * @offset: not used
+ *
+ * Return: always 0
  */
 int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)
 {
@@ -1927,6 +1938,8 @@ out:
 /**
  * batadv_nc_init_debugfs - create nc folder and related files in debugfs
  * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 int batadv_nc_init_debugfs(struct batadv_priv *bat_priv)
 {
-- 
2.7.0
