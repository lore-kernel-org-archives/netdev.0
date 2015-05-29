From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 15/16] batman-adv: iv_ogm_orig_update, remove unnecessary brackets
Date: Fri, 29 May 2015 11:05:27 +0200
Message-ID: <1432890328-8247-16-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:20262 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755613AbbE2JaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:30:07 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Remove these unnecessary brackets inside a condition.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ce04cd7..c5ba7a7 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1081,7 +1081,7 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 	 * won't consider it either
 	 */
 	if (router_ifinfo &&
-	    (neigh_ifinfo->bat_iv.tq_avg == router_ifinfo->bat_iv.tq_avg)) {
+	    neigh_ifinfo->bat_iv.tq_avg == router_ifinfo->bat_iv.tq_avg) {
 		orig_node_tmp = router->orig_node;
 		spin_lock_bh(&orig_node_tmp->bat_iv.ogm_cnt_lock);
 		if_num = router->if_incoming->if_num;
-- 
2.4.2
