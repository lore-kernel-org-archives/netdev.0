From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 16/16] batman-adv: Add kerneldoc for batadv_neigh_node::refcount
Date: Sat,  9 Jan 2016 21:20:21 +0800
Message-ID: <1452345621-15908-17-git-send-email-a__6372.60362641445$1452346839$gmane$org@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:14359 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755099AbcAINkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:40:33 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1a67a1a402f6..3437b667a2cd 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -371,6 +371,7 @@ struct batadv_hardif_neigh_node {
  * @ifinfo_lock: lock protecting private ifinfo members and list
  * @if_incoming: pointer to incoming hard interface
  * @last_seen: when last packet via this neighbor was received
+ * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
  */
 struct batadv_neigh_node {
-- 
2.7.0
