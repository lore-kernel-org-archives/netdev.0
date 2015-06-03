From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/12] batman-adv: iv_ogm_orig_update, style, add missing brackets
Date: Wed,  3 Jun 2015 16:13:59 +0200
Message-ID: <1433340848-1682-4-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:33762 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932590AbbFCOQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:15 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

CodingStyle describes that either none or both branches of a conditional
have to have brackets.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 159f30a..66ac9e8 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1032,9 +1032,10 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 		batadv_orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
 			goto unlock;
-	} else
+	} else {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Updating existing last-hop neighbor of originator\n");
+	}
 
 	rcu_read_unlock();
 	neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node, if_outgoing);
-- 
2.4.2
