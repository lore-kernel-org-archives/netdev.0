From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 09/13] batman-adv: Remove unused definitions
Date: Sat, 29 Jan 2011 22:47:36 +0100
Message-ID: <1296337660-12376-10-git-send-email-sven@narfation.org>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1296337660-12376-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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
 #define DRIVER_AUTHOR "Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, " \
 		      "Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>"
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
