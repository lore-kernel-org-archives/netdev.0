From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 5/9] batman-adv: Remove unused definitions
Date: Mon, 31 Jan 2011 16:20:47 +0100
Message-ID: <1296487251-12552-6-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42656 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab1AaPVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:19 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.h |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 65106fb..c1ace85 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -22,9 +22,6 @@
 #ifndef _NET_BATMAN_ADV_MAIN_H_
 #define _NET_BATMAN_ADV_MAIN_H_
 
-/* Kernel Programming */
-#define LINUX
-
 #define DRIVER_AUTHOR "Marek Lindner <lindner_marek@yahoo.de>, " \
 		      "Simon Wunderlich <siwu@hrz.tu-chemnitz.de>"
 #define DRIVER_DESC   "B.A.T.M.A.N. advanced"
@@ -54,7 +51,6 @@
 
 #define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
 
-#define PACKBUFF_SIZE 2000
 #define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
 #define VIS_INTERVAL 5000	/* 5 seconds */
@@ -96,15 +92,11 @@
 #define DBG_ROUTES 2	/* route or hna added / changed / deleted */
 #define DBG_ALL 3
 
-#define LOG_BUF_LEN 8192          /* has to be a power of 2 */
-
 
 /*
  *  Vis
  */
 
-/* #define VIS_SUBCLUSTERS_DISABLED */
-
 /*
  * Kernel headers
  */
@@ -158,13 +150,6 @@ static inline void bat_dbg(char type __always_unused,
 }
 #endif
 
-#define bat_warning(net_dev, fmt, arg...)				\
-	do {								\
-		struct net_device *_netdev = (net_dev);                 \
-		struct bat_priv *_batpriv = netdev_priv(_netdev);       \
-		bat_dbg(DBG_ALL, _batpriv, fmt, ## arg);		\
-		pr_warning("%s: " fmt, _netdev->name, ## arg);		\
-	} while (0)
 #define bat_info(net_dev, fmt, arg...)					\
 	do {								\
 		struct net_device *_netdev = (net_dev);                 \
-- 
1.7.2.3

