From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] rtlwifi: rtl8821ae: Remove duplicate hex prefixes
Date: Mon, 23 Feb 2015 13:05:59 +0100
Message-ID: <1424693160-7805-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The # flag in %X means print a 0X prefix. Remove the extra 0x prefix.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
The file uses a mix of explicit 0x prefixes and # flags, as well as a
mix of %x and %X, so it's not clear what the most consistent choice
would be.

 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index 8ec8200002c7..3aca53d9acfb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -1515,7 +1515,7 @@ static bool _rtl8821ae_dynamic_rqpn(struct ieee80211_hw *hw, u32 boundary,
 				      (u8 *)(&support_remote_wakeup));
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "boundary=0x%#X, NPQ_RQPNValue=0x%#X, RQPNValue=0x%#X\n",
+		 "boundary=%#X, NPQ_RQPNValue=%#X, RQPNValue=%#X\n",
 		  boundary, npq_rqpn_value, rqpn_val);
 
 	/* stop PCIe DMA
-- 
2.1.3
