From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wl12xx: remove redundant null check on wl->scan.ssid
Date: Fri, 18 Mar 2016 16:20:48 +0000
Message-ID: <1458318048-28184-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, Arik Nemtsov <arik@wizery.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Avraham Stern <avraham.stern@intel.com>,
	Eliad Peller <eliad@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

ssid is an array of u8, so it can never be null, so the null check on
wl->scan.ssid is redundant and can be removed.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ti/wl12xx/scan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl12xx/scan.c b/drivers/net/wireless/ti/wl12xx/scan.c
index ebed13a..a0dfc59 100644
--- a/drivers/net/wireless/ti/wl12xx/scan.c
+++ b/drivers/net/wireless/ti/wl12xx/scan.c
@@ -149,7 +149,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	else
 		cmd->params.band = WL1271_SCAN_BAND_5_GHZ;
 
-	if (wl->scan.ssid_len && wl->scan.ssid) {
+	if (wl->scan.ssid_len) {
 		cmd->params.ssid_len = wl->scan.ssid_len;
 		memcpy(cmd->params.ssid, wl->scan.ssid, wl->scan.ssid_len);
 	}
-- 
2.7.3
