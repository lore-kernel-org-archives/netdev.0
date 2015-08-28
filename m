From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/10] batman-adv: remove redundant hard_iface assignment
Date: Fri, 28 Aug 2015 11:12:28 +0200
Message-ID: <1440753156-7808-3-git-send-email-antonio@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:40896 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbbH1JNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:53 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The batadv_neigh_node_new() function already sets the hard_iface pointer.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b9b8b33..b18184e 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -304,7 +304,6 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 		goto out;
 
 	neigh_node->orig_node = orig_neigh;
-	neigh_node->if_incoming = hard_iface;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	tmp_neigh_node = batadv_neigh_node_get(orig_node, hard_iface,
-- 
2.5.0
