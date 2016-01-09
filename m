From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 03/16] batman-adv: remove leftovers of unused BATADV_PRIMARIES_FIRST_HOP flag
Date: Sat,  9 Jan 2016 21:20:08 +0800
Message-ID: <1452345621-15908-4-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:17402 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754875AbcAINWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:21 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 3 ---
 net/batman-adv/packet.h     | 3 +--
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5677169c1b98..246702486228 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -361,7 +361,6 @@ batadv_iv_ogm_primary_iface_set(struct batadv_hard_iface *hard_iface)
 	unsigned char *ogm_buff = hard_iface->bat_iv.ogm_buff;
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)ogm_buff;
-	batadv_ogm_packet->flags = BATADV_PRIMARIES_FIRST_HOP;
 	batadv_ogm_packet->ttl = BATADV_TTL;
 }
 
@@ -842,8 +841,6 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 		   "Forwarding packet: tq: %i, ttl: %i\n",
 		   batadv_ogm_packet->tq, batadv_ogm_packet->ttl);
 
-	/* switch of primaries first hop flag when forwarding */
-	batadv_ogm_packet->flags &= ~BATADV_PRIMARIES_FIRST_HOP;
 	if (is_single_hop_neigh)
 		batadv_ogm_packet->flags |= BATADV_DIRECTLINK;
 	else
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 11f996b39fef..0558e3237e0e 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -72,8 +72,7 @@ enum batadv_subtype {
  * enum batadv_iv_flags - flags used in B.A.T.M.A.N. IV OGM packets
  * @BATADV_NOT_BEST_NEXT_HOP: flag is set when ogm packet is forwarded and was
  *     previously received from someone else than the best neighbor.
- * @BATADV_PRIMARIES_FIRST_HOP: flag is set when the primary interface address
- *     is used, and the packet travels its first hop.
+ * @BATADV_PRIMARIES_FIRST_HOP: flag unused.
  * @BATADV_DIRECTLINK: flag is for the first hop or if rebroadcasted from a
  *     one hop neighbor on the interface where it was originally received.
  */
-- 
2.7.0
