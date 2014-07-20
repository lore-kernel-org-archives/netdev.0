From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 05/30] rtlwifi: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:13 +0200
Message-ID: <1405865801-18806-6-git-send-email-fabf@skynet.be>
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
 drivers/net/wireless/rtlwifi/core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index b1ed6d0..56e218e 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1064,7 +1064,6 @@ static int rtl_op_ampdu_action(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_START: TID:%d\n", tid);
 		return rtl_tx_agg_start(hw, sta, tid, ssn);
-		break;
 	case IEEE80211_AMPDU_TX_STOP_CONT:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH_CONT:
-- 
1.9.1
