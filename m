From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath10k: fix spelling mistake "montior" -> "monitor"
Date: Fri, 26 Aug 2016 19:08:52 +0100
Message-ID: <20160826180852.32248-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in ath10k_warn message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath10k/mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 0bbd0a0..841f288 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -5186,7 +5186,7 @@ static void ath10k_configure_filter(struct ieee80211_hw *hw,
 
 	ret = ath10k_monitor_recalc(ar);
 	if (ret)
-		ath10k_warn(ar, "failed to recalc montior: %d\n", ret);
+		ath10k_warn(ar, "failed to recalc monitor: %d\n", ret);
 
 	mutex_unlock(&ar->conf_mutex);
 }
-- 
2.9.3
