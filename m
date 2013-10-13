From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/16] batman-adv: remove batadv_tt_global_add_orig declaration
Date: Sun, 13 Oct 2013 13:22:48 +0200
Message-ID: <1381663381-626-4-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:30461 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327Ab3JMLYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:20 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

batadv_tt_global_add_orig is neither used nor implemented
anymore, therefore it is possible to remove its declaration

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index fb710c5..015d8b9 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -27,9 +27,6 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 				const uint8_t *addr, const char *message,
 				bool roaming);
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset);
-void batadv_tt_global_add_orig(struct batadv_priv *bat_priv,
-			       struct batadv_orig_node *orig_node,
-			       const unsigned char *tt_buff, int tt_buff_len);
 int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-- 
1.8.3.2
