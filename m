From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/6 V3.18] rtlwifi: rtl8821ae: Remove extra semicolons
Date: Wed, 29 Oct 2014 23:17:12 -0500
Message-ID: <1414642633-3700-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:48053 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbaJ3ER3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 00:17:29 -0400
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot reports that there are extra semicolons in this
driver. All of them are caused by using "};" rather than "}" at the
end of a switch statement. This patch does not change any functionality.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
index 1e9570f..9b4d8a6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
@@ -800,7 +800,7 @@ static void _rtl8821ae_phy_set_txpower_by_rate_base(struct ieee80211_hw *hw,
 				 "Invalid RateSection %d in Band 2.4G,Rf Path %d, %dTx in PHY_SetTxPowerByRateBase()\n",
 				 rate_section, path, txnum);
 			break;
-		};
+		}
 	} else if (band == BAND_ON_5G) {
 		switch (rate_section) {
 		case OFDM:
@@ -823,7 +823,7 @@ static void _rtl8821ae_phy_set_txpower_by_rate_base(struct ieee80211_hw *hw,
 				"Invalid RateSection %d in Band 5G, Rf Path %d, %dTx in PHY_SetTxPowerByRateBase()\n",
 				rate_section, path, txnum);
 			break;
-		};
+		}
 	} else {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			"Invalid Band %d in PHY_SetTxPowerByRateBase()\n", band);
@@ -870,7 +870,7 @@ static u8 _rtl8821ae_phy_get_txpower_by_rate_base(struct ieee80211_hw *hw,
 				 "Invalid RateSection %d in Band 2.4G, Rf Path %d, %dTx in PHY_GetTxPowerByRateBase()\n",
 				 rate_section, path, txnum);
 			break;
-		};
+		}
 	} else if (band == BAND_ON_5G) {
 		switch (rate_section) {
 		case OFDM:
@@ -893,7 +893,7 @@ static u8 _rtl8821ae_phy_get_txpower_by_rate_base(struct ieee80211_hw *hw,
 				 "Invalid RateSection %d in Band 5G, Rf Path %d, %dTx in PHY_GetTxPowerByRateBase()\n",
 				 rate_section, path, txnum);
 			break;
-		};
+		}
 	} else {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "Invalid Band %d in PHY_GetTxPowerByRateBase()\n", band);
@@ -3746,7 +3746,7 @@ static void _rtl8821ae_iqk_tx_fill_iqc(struct ieee80211_hw *hw,
 		break;
 	default:
 		break;
-	};
+	}
 }
 
 static void _rtl8821ae_iqk_rx_fill_iqc(struct ieee80211_hw *hw,
@@ -3767,7 +3767,7 @@ static void _rtl8821ae_iqk_rx_fill_iqc(struct ieee80211_hw *hw,
 		break;
 	default:
 		break;
-	};
+	}
 }
 
 #define cal_num 10
-- 
2.1.1
