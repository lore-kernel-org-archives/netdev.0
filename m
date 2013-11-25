From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8188ee: Fix typo in code
Date: Mon, 25 Nov 2013 10:45:28 -0600
Message-ID: <1385397928-17159-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, David Binderman <dcb314@hotmail.com>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The static analyser "cppcheck" shows the following typo:
drivers/net/wireless/rtlwifi/rtl8188ee/dm.c:1081]: (style) Same expression on both sides of '!='.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: David Binderman <dcb314@hotmail.com>
Cc: David Binderman <dcb314@hotmail.com>
Cc: Stable <stable@vger.kernel.org> [3.10+]
---
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index 21a5cf0..a6184b6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
@@ -1078,7 +1078,7 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 				rtldm->swing_flag_ofdm = true;
 			}
 
-			if (rtldm->swing_idx_cck != rtldm->swing_idx_cck) {
+			if (rtldm->swing_idx_cck_cur != rtldm->swing_idx_cck) {
 				rtldm->swing_idx_cck_cur = rtldm->swing_idx_cck;
 				rtldm->swing_flag_cck = true;
 			}
-- 
1.8.4
