From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 08/15] batman-adv: Fix checkpatch warning about 'unsigned' type
Date: Wed,  4 May 2016 06:23:43 +0800
Message-ID: <1462314230-16257-9-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:2733 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756786AbcECWYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:49 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

checkpatch.pl warns about the use of 'unsigned' as a short form for
'unsigned int'.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/fragmentation.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index e6956d0746a2..65536db1bff7 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -407,8 +407,8 @@ static struct sk_buff *batadv_frag_create(struct sk_buff *skb,
 					  unsigned int mtu)
 {
 	struct sk_buff *skb_fragment;
-	unsigned header_size = sizeof(*frag_head);
-	unsigned fragment_size = mtu - header_size;
+	unsigned int header_size = sizeof(*frag_head);
+	unsigned int fragment_size = mtu - header_size;
 
 	skb_fragment = netdev_alloc_skb(NULL, mtu + ETH_HLEN);
 	if (!skb_fragment)
@@ -444,15 +444,15 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_frag_packet frag_header;
 	struct sk_buff *skb_fragment;
-	unsigned mtu = neigh_node->if_incoming->net_dev->mtu;
-	unsigned header_size = sizeof(frag_header);
-	unsigned max_fragment_size, max_packet_size;
+	unsigned int mtu = neigh_node->if_incoming->net_dev->mtu;
+	unsigned int header_size = sizeof(frag_header);
+	unsigned int max_fragment_size, max_packet_size;
 	bool ret = false;
 
 	/* To avoid merge and refragmentation at next-hops we never send
 	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
 	 */
-	mtu = min_t(unsigned, mtu, BATADV_FRAG_MAX_FRAG_SIZE);
+	mtu = min_t(unsigned int, mtu, BATADV_FRAG_MAX_FRAG_SIZE);
 	max_fragment_size = mtu - header_size;
 	max_packet_size = max_fragment_size * BATADV_FRAG_MAX_FRAGMENTS;
 
-- 
2.8.2
