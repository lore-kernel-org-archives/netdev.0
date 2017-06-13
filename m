From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] rtlwifi: rtl8821ae: remove unused variable
Date: Tue, 13 Jun 2017 15:42:59 -0500
Message-ID: <20170613204259.GA9189@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unused variable rtlhal.

Addresses-Coverity-ID: 1248810
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 2bc6bac..d158e34 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -1360,7 +1360,6 @@ static bool _rtl8821ae_reset_pcie_interface_dma(struct ieee80211_hw *hw,
 static void _rtl8821ae_get_wakeup_reason(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
 	u8 fw_reason = 0;
 	struct timeval ts;
@@ -1372,8 +1371,6 @@ static void _rtl8821ae_get_wakeup_reason(struct ieee80211_hw *hw)
 
 	ppsc->wakeup_reason = 0;
 
-	rtlhal->last_suspend_sec = ts.tv_sec;
-
 	switch (fw_reason) {
 	case FW_WOW_V2_PTK_UPDATE_EVENT:
 		ppsc->wakeup_reason = WOL_REASON_PTK_UPDATE;
-- 
2.5.0
