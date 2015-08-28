From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/10] batman-adv: fix gateway client style issues
Date: Fri, 28 Aug 2015 11:12:32 +0200
Message-ID: <1440753156-7808-7-git-send-email-antonio@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:38542 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbbH1JN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:56 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

commit 0511575c4d03 ("batman-adv: remove obsolete deleted attribute for
gateway node") incorrectly added an empy line and forgot to remove an
include.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 634c7e3..e6c8382 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -27,7 +27,6 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
-#include <linux/jiffies.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
@@ -565,7 +564,6 @@ void batadv_gw_node_free(struct batadv_priv *bat_priv)
 	spin_lock_bh(&bat_priv->gw.list_lock);
 	hlist_for_each_entry_safe(gw_node, node_tmp,
 				  &bat_priv->gw.list, list) {
-
 		hlist_del_init_rcu(&gw_node->list);
 		batadv_gw_node_free_ref(gw_node);
 	}
-- 
2.5.0
