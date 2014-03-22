From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/16] batman-adv: fix a few kerneldoc inconsistencies
Date: Sat, 22 Mar 2014 09:56:05 +0100
Message-ID: <1395478576-10999-6-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:28498 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaCVI4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:55 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Reported-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/types.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 78370ab..9f52517 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -163,7 +163,7 @@ struct batadv_vlan_tt {
 };
 
 /**
- * batadv_orig_node_vlan - VLAN specific data per orig_node
+ * struct batadv_orig_node_vlan - VLAN specific data per orig_node
  * @vid: the VLAN identifier
  * @tt: VLAN specific TT attributes
  * @list: list node for orig_node::vlan_list
@@ -334,7 +334,7 @@ struct batadv_neigh_node {
 };
 
 /**
- * struct batadv_neigh_node_bat_iv - neighbor information per outgoing
+ * struct batadv_neigh_ifinfo_bat_iv - neighbor information per outgoing
  *  interface for BATMAN IV
  * @tq_recv: ring buffer of received TQ values from this neigh node
  * @tq_index: ring buffer index
@@ -544,7 +544,7 @@ struct batadv_priv_bla {
 #endif
 
 /**
- * struct batadv_debug_log - debug logging data
+ * struct batadv_priv_debug_log - debug logging data
  * @log_buff: buffer holding the logs (ring bufer)
  * @log_start: index of next character to read
  * @log_end: index of next character to write
@@ -1004,8 +1004,8 @@ struct batadv_nc_packet {
 };
 
 /**
- * batadv_skb_cb - control buffer structure used to store private data relevant
- *  to batman-adv in the skb->cb buffer in skbs.
+ * struct batadv_skb_cb - control buffer structure used to store private data
+ *  relevant to batman-adv in the skb->cb buffer in skbs.
  * @decoded: Marks a skb as decoded, which is checked when searching for coding
  *  opportunities in network-coding.c
  */
-- 
1.8.3.2
