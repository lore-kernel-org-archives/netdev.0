From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/16] batman-adv: add kernel-doc for enum batadv_dbg_level
Date: Mon, 29 Oct 2012 09:58:17 +0100
Message-ID: <1351501097-1289-17-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54174 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758218Ab2J2I7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:08 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 9b94f05..897ba6a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -165,12 +165,19 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 
-/* all messages related to routing / flooding / broadcasting / etc */
+/**
+ * enum batadv_dbg_level - available log levels
+ * @BATADV_DBG_BATMAN: OGM and TQ computations related messages
+ * @BATADV_DBG_ROUTES: route added / changed / deleted
+ * @BATADV_DBG_TT: translation table messages
+ * @BATADV_DBG_BLA: bridge loop avoidance messages
+ * @BATADV_DBG_ALL: the union of all the above log levels
+ */
 enum batadv_dbg_level {
 	BATADV_DBG_BATMAN = BIT(0),
-	BATADV_DBG_ROUTES = BIT(1), /* route added / changed / deleted */
-	BATADV_DBG_TT	  = BIT(2), /* translation table operations */
-	BATADV_DBG_BLA    = BIT(3), /* bridge loop avoidance */
+	BATADV_DBG_ROUTES = BIT(1),
+	BATADV_DBG_TT	  = BIT(2),
+	BATADV_DBG_BLA    = BIT(3),
 	BATADV_DBG_ALL    = 15,
 };
 
-- 
1.7.12.4
