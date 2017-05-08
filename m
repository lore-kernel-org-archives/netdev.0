From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: [PATCH] drivers: net: wireless: rsi: rsi_91x_core: Use time_after time comparison
Date: Tue,  9 May 2017 00:34:10 +0200
Message-ID: <1494282850-13782-1-git-send-email-karim.eshapa@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use time_after kernel macro for time comparison.

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/wireless/rsi/rsi_91x_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_core.c b/drivers/net/wireless/rsi/rsi_91x_core.c
index f3d3995..68f04a7 100644
--- a/drivers/net/wireless/rsi/rsi_91x_core.c
+++ b/drivers/net/wireless/rsi/rsi_91x_core.c
@@ -306,7 +306,7 @@ void rsi_core_qos_processor(struct rsi_common *common)
 		tstamp_2 = jiffies;
 		mutex_unlock(&common->tx_rxlock);
 
-		if (tstamp_2 > tstamp_1 + (300 * HZ / 1000))
+		if (time_after(tstamp_2, tstamp_1 + (300 * HZ) / 1000))
 			schedule();
 	}
 }
-- 
2.7.4
