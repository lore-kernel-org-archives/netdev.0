From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 2/4] batman-adv: Don't begin block comments with only a /* line
Date: Sun, 11 Mar 2012 06:44:49 +0800
Message-ID: <1331419491-21333-3-git-send-email-lindner_marek@yahoo.de>
References: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm23-vm1.bullet.mail.ukl.yahoo.com ([217.146.177.100]:33767
	"HELO nm23-vm1.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752294Ab2CJWpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 17:45:46 -0500
In-Reply-To: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c |    3 +--
 net/batman-adv/main.h       |   13 ++-----------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 677997b..a6d5d63 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -779,8 +779,7 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 		 * information */
 		tq_own = (TQ_MAX_VALUE * total_count) /	neigh_rq_count;
 
-	/*
-	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
+	/* 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
 	 * affect the nearly-symmetric links only a little, but
 	 * punishes asymmetric links more.  This will give a value
 	 * between 0 and TQ_MAX_VALUE
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 1468788..94fa1c2 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -107,9 +107,7 @@ enum uev_type {
 
 #define GW_THRESHOLD	50
 
-/*
- * Debug Messages
- */
+/* Debug Messages */
 #ifdef pr_fmt
 #undef pr_fmt
 #endif
@@ -124,14 +122,7 @@ enum dbg_level {
 	DBG_ALL    = 7
 };
 
-
-/*
- *  Vis
- */
-
-/*
- * Kernel headers
- */
+/* Kernel headers */
 
 #include <linux/mutex.h>	/* mutex */
 #include <linux/module.h>	/* needed by all modules */
-- 
1.7.9.1
