From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 07/30] rtlwifi: rtl8192se: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:15 +0200
Message-ID: <1405865801-18806-8-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c | 3 ---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c | 1 -
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
index 380e7d4..b15aa5c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -112,13 +112,10 @@ static u8 _rtl92s_firmware_header_map_rftype(struct ieee80211_hw *hw)
 	switch (rtlphy->rf_type) {
 	case RF_1T1R:
 		return 0x11;
-		break;
 	case RF_1T2R:
 		return 0x12;
-		break;
 	case RF_2T2R:
 		return 0x22;
-		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Unknown RF type(%x)\n",
 			 rtlphy->rf_type);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 1c7101b..00e0670 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1198,7 +1198,6 @@ static int _rtl92se_set_media_status(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Network type %d not supported!\n", type);
 		return 1;
-		break;
 
 	}
 
-- 
1.9.1
