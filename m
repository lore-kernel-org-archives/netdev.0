From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 2/5] batman-adv: init neigh node last seen field
Date: Tue, 26 Apr 2016 11:27:16 +0800
Message-ID: <1461641239-7097-3-git-send-email-a@unstable.cc>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:37603 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbcDZD2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:28:05 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/originator.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index e4cbb0753e37..d52f67a0c057 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -663,6 +663,7 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 	ether_addr_copy(neigh_node->addr, neigh_addr);
 	neigh_node->if_incoming = hard_iface;
 	neigh_node->orig_node = orig_node;
+	neigh_node->last_seen = jiffies;
 
 	/* extra reference for return */
 	kref_init(&neigh_node->refcount);
-- 
2.8.1
