From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 03/10] net: wireless: rtwifi: Remove duplicated arguments to |
Date: Wed, 28 Oct 2015 00:32:38 +0530
Message-ID: <1445972565-14963-3-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove uncessary repeated arguments COMP_EFUSE, COMP_REGD, COMP_CHAN
 with OR(|)

This is patch to the debug.c file that removes following warning
reported by coccicheck:

-duplicated argument to & or |

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/rtlwifi/debug.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.c b/drivers/net/wireless/rtlwifi/debug.c
index fd25aba..b8f5540 100644
--- a/drivers/net/wireless/rtlwifi/debug.c
+++ b/drivers/net/wireless/rtlwifi/debug.c
@@ -37,9 +37,9 @@ void rtl_dbgp_flag_init(struct ieee80211_hw *hw)
 	    COMP_BEACON | COMP_RATE | COMP_RXDESC | COMP_DIG | COMP_TXAGC |
 	    COMP_POWER | COMP_POWER_TRACKING | COMP_BB_POWERSAVING | COMP_SWAS |
 	    COMP_RF | COMP_TURBO | COMP_RATR | COMP_CMD |
-	    COMP_EFUSE | COMP_QOS | COMP_MAC80211 | COMP_REGD | COMP_CHAN |
-	    COMP_EASY_CONCURRENT | COMP_EFUSE | COMP_QOS | COMP_MAC80211 |
-	    COMP_REGD | COMP_CHAN | COMP_BT_COEXIST;
+	    COMP_EFUSE | COMP_QOS | COMP_MAC80211 | COMP_CHAN |
+	    COMP_EASY_CONCURRENT | COMP_QOS | COMP_MAC80211 |
+	    COMP_REGD | COMP_BT_COEXIST;
 
 
 	for (i = 0; i < DBGP_TYPE_MAX; i++)
-- 
2.5.3
