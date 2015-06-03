From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/12] batman-adv: types, Fix comment on bcast_own
Date: Wed,  3 Jun 2015 16:14:03 +0200
Message-ID: <1433340848-1682-8-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:10832 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932620AbbFCOQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:21 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

batadv_orig_bat_iv->bcast_own is actually not a bitfield, it is an
array. Adjust the comment accordingly.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/types.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e95db42..c1000c0 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -183,9 +183,10 @@ struct batadv_orig_node_vlan {
 
 /**
  * struct batadv_orig_bat_iv - B.A.T.M.A.N. IV private orig_node members
- * @bcast_own: bitfield containing the number of our OGMs this orig_node
- *  rebroadcasted "back" to us (relative to last_real_seqno)
- * @bcast_own_sum: counted result of bcast_own
+ * @bcast_own: set of bitfields (one per hard interface) where each one counts
+ * the number of our OGMs this orig_node rebroadcasted "back" to us  (relative
+ * to last_real_seqno). Every bitfield is BATADV_TQ_LOCAL_WINDOW_SIZE bits long.
+ * @bcast_own_sum: sum of bcast_own
  * @ogm_cnt_lock: lock protecting bcast_own, bcast_own_sum,
  *  neigh_node->bat_iv.real_bits & neigh_node->bat_iv.real_packet_count
  */
-- 
2.4.2
