From: Luis de Bethencourt <luisbg@ubuntu.com>
Subject: [PATCH 2/2] ath: fix macros coding style issue in regd.c
Date: Tue, 30 Mar 2010 00:12:19 +0100
Message-ID: <1269904339-15599-1-git-send-email-luisbg@ubuntu.com>
References: <regd.c>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Luis de Bethencourt <luisbg@ubuntu.com>
To: linville@tuxdriver.com, lrodriguez@atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <regd.c>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a patch to the ath/regd.c file that fixes up three warnings
about macros found by the checkpatch.pl tool, these said that
complex values should be enclosed in parenthesis.

Signed-off-by: Luis de Bethencourt <luisbg@ubuntu.com>
---
 drivers/net/wireless/ath/regd.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/regd.c
index 04abd1f..971edc4 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -45,15 +45,16 @@
 #define ATH9K_5GHZ_5725_5850	REG_RULE(5725-10, 5850+10, 40, 0, 30,\
 				NL80211_RRF_PASSIVE_SCAN | NL80211_RRF_NO_IBSS)
 
-#define ATH9K_2GHZ_ALL		ATH9K_2GHZ_CH01_11, \
+#define ATH9K_2GHZ_ALL		(ATH9K_2GHZ_CH01_11, \
 				ATH9K_2GHZ_CH12_13, \
-				ATH9K_2GHZ_CH14
+				ATH9K_2GHZ_CH14)
+
+#define ATH9K_5GHZ_ALL		(ATH9K_5GHZ_5150_5350, \
+				ATH9K_5GHZ_5470_5850)
 
-#define ATH9K_5GHZ_ALL		ATH9K_5GHZ_5150_5350, \
-				ATH9K_5GHZ_5470_5850
 /* This one skips what we call "mid band" */
-#define ATH9K_5GHZ_NO_MIDBAND	ATH9K_5GHZ_5150_5350, \
-				ATH9K_5GHZ_5725_5850
+#define ATH9K_5GHZ_NO_MIDBAND	(ATH9K_5GHZ_5150_5350, \
+				ATH9K_5GHZ_5725_5850)
 
 /* Can be used for:
  * 0x60, 0x61, 0x62 */
-- 
1.6.3.3
