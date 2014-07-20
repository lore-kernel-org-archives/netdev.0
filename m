From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 06/30] rtlwifi: rtl8192ce: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:14 +0200
Message-ID: <1405865801-18806-7-git-send-email-fabf@skynet.be>
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
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index cdecb0f..0c43c8f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1200,7 +1200,6 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Network type %d not supported!\n", type);
 		return 1;
-		break;
 
 	}
 
-- 
1.9.1
