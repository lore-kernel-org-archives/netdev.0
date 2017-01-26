From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 5/7] batman-adv: Remove unused variable in batadv_tt_local_set_flags
Date: Thu, 26 Jan 2017 17:44:02 +0100
Message-ID: <20170126164404.16074-6-sw@simonwunderlich.de>
References: <20170126164404.16074-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54088 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbdAZQoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:44:17 -0500
In-Reply-To: <20170126164404.16074-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/translation-table.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 941afad92121..6077a87d46f0 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3714,7 +3714,6 @@ static void batadv_tt_local_set_flags(struct batadv_priv *bat_priv, u16 flags,
 {
 	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common_entry;
-	u16 changed_num = 0;
 	struct hlist_head *head;
 	u32 i;
 
@@ -3736,7 +3735,6 @@ static void batadv_tt_local_set_flags(struct batadv_priv *bat_priv, u16 flags,
 					continue;
 				tt_common_entry->flags &= ~flags;
 			}
-			changed_num++;
 
 			if (!count)
 				continue;
-- 
2.11.0
