From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/12] batman-adv: unify flags access style in tt global add
Date: Wed, 16 Dec 2015 15:49:30 +0800
Message-ID: <1450252173-20949-10-git-send-email-antonio@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:19617 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965482AbbLPHvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:37 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

This should slightly improve readability

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 17822de..5cf4311 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1435,7 +1435,7 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 		 * TT_CLIENT_WIFI, therefore they have to be copied in the
 		 * client entry
 		 */
-		tt_global_entry->common.flags |= flags;
+		common->flags |= flags;
 
 		/* If there is the BATADV_TT_CLIENT_ROAM flag set, there is only
 		 * one originator left in the list and we previously received a
-- 
2.6.4
