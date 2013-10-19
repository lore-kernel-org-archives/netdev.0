From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/18] batman-adv: remove bogus comment
Date: Sun, 20 Oct 2013 00:22:06 +0200
Message-ID: <1382221330-3769-15-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12100 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689Ab3JSWju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:39:50 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

this comment refers to the old batmand codebase and does
not make sense anymore. Remove it

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 4ed410f..20fa053 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -221,11 +221,6 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *router = NULL;
 	char gw_addr[18] = { '\0' };
 
-	/* The batman daemon checks here if we already passed a full originator
-	 * cycle in order to make sure we don't choose the first gateway we
-	 * hear about. This check is based on the daemon's uptime which we
-	 * don't have.
-	 */
 	if (atomic_read(&bat_priv->gw_mode) != BATADV_GW_MODE_CLIENT)
 		goto out;
 
-- 
1.8.4
