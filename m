From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 15/16] batman-adv: Remove kerneldoc for missing struct members
Date: Sat,  9 Jan 2016 21:20:20 +0800
Message-ID: <1452345621-15908-16-git-send-email-a__15578.8237498657$1452346816$gmane$org@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:35229 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194AbcAINkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:40:05 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/types.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d93501edb987..1a67a1a402f6 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -371,9 +371,7 @@ struct batadv_hardif_neigh_node {
  * @ifinfo_lock: lock protecting private ifinfo members and list
  * @if_incoming: pointer to incoming hard interface
  * @last_seen: when last packet via this neighbor was received
- * @last_ttl: last received ttl from this neigh node
  * @rcu: struct used for freeing in an RCU-safe manner
- * @bat_iv: B.A.T.M.A.N. IV private structure
  */
 struct batadv_neigh_node {
 	struct hlist_node list;
@@ -1257,8 +1255,6 @@ struct batadv_dat_candidate {
  * struct batadv_tvlv_container - container for tvlv appended to OGMs
  * @list: hlist node for batadv_priv_tvlv::container_list
  * @tvlv_hdr: tvlv header information needed to construct the tvlv
- * @value_len: length of the buffer following this struct which contains
- *  the actual tvlv payload
  * @refcount: number of contexts the object is used
  */
 struct batadv_tvlv_container {
-- 
2.7.0
