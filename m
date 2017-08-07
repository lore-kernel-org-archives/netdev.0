From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2] rtlwifi: constify rate_control_ops structure
Date: Mon,  7 Aug 2017 10:30:51 +0530
Message-ID: <1502082051-4904-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rate_control_ops structure is only passed as an argument to the
function ieee80211_rate_control_{register/unregister}. This argument
is of type const, so declare the structure as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
Changes in v2:
* Change subject line.

 drivers/net/wireless/realtek/rtlwifi/rc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rc.c b/drivers/net/wireless/realtek/rtlwifi/rc.c
index 951d257..02811ed 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rc.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rc.c
@@ -283,7 +283,7 @@ static void rtl_rate_free_sta(void *rtlpriv,
 	kfree(rate_priv);
 }
 
-static struct rate_control_ops rtl_rate_ops = {
+static const struct rate_control_ops rtl_rate_ops = {
 	.name = "rtl_rc",
 	.alloc = rtl_rate_alloc,
 	.free = rtl_rate_free,
-- 
1.9.1
