From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 16/18] ipw2200: rename CONFIG_IEEE80211_RADIOTAP to CONFIG_IPW2200_RADIOTAP
Date: Thu, 13 Apr 2006 17:21:00 +0800
Message-ID: <20060413092100.GA28815@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:38605 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964856AbWDMJ2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:28:05 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   12 ++++++------
 drivers/net/wireless/ipw2200.h |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

70646d6a1c055a3bbd5b29f471ca49d43c534267
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 426f306..62ebec8 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -58,7 +58,7 @@
 #define VP
 #endif
 
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 #define VR "r"
 #else
 #define VR
@@ -7586,7 +7586,7 @@ static void ipw_handle_data_packet(struc
 	}
 }
 
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 static void ipw_handle_data_packet_monitor(struct ipw_priv *priv,
 					   struct ipw_rx_mem_buffer *rxb,
 					   struct ieee80211_rx_stats *stats)
@@ -8194,7 +8194,7 @@ static void ipw_rx(struct ipw_priv *priv
 
 #ifdef CONFIG_IPW2200_MONITOR
 				if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 
                 ipw_handle_data_packet_monitor(priv,
 					       rxb,
@@ -8381,7 +8381,7 @@ static int ipw_sw_reset(struct ipw_priv 
 #ifdef CONFIG_IPW2200_MONITOR
 	case 2:
 		priv->ieee->iw_mode = IW_MODE_MONITOR;
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 		priv->net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 #else
 		priv->net_dev->type = ARPHRD_IEEE80211;
@@ -8636,7 +8636,7 @@ static int ipw_wx_set_mode(struct net_de
 		priv->net_dev->type = ARPHRD_ETHER;
 
 	if (wrqu->mode == IW_MODE_MONITOR)
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 		priv->net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 #else
 		priv->net_dev->type = ARPHRD_IEEE80211;
@@ -9738,7 +9738,7 @@ static int ipw_wx_set_monitor(struct net
 	IPW_DEBUG_WX("SET MONITOR: %d %d\n", enable, parms[1]);
 	if (enable) {
 		if (priv->ieee->iw_mode != IW_MODE_MONITOR) {
-#ifdef CONFIG_IEEE80211_RADIOTAP
+#ifdef CONFIG_IPW2200_RADIOTAP
 			priv->net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 #else
 			priv->net_dev->type = ARPHRD_IEEE80211;
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 14fe79a..6044c0b 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1146,7 +1146,7 @@ struct ipw_prom_priv {
 };
 #endif
 
-#if defined(CONFIG_IEEE80211_RADIOTAP) || defined(CONFIG_IPW2200_PROMISCUOUS)
+#if defined(CONFIG_IPW2200_RADIOTAP) || defined(CONFIG_IPW2200_PROMISCUOUS)
 /* Magic struct that slots into the radiotap header -- no reason
  * to build this manually element by element, we can write it much
  * more efficiently than we can parse it. ORDER MATTERS HERE
-- 
1.2.6

