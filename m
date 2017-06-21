From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] ath10k: add const to thermal_cooling_device_ops structure
Date: Wed, 21 Jun 2017 14:53:30 +0530
Message-ID: <1498037010-21024-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, kvalo@qca.qualcomm.com,
        ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare thermal_cooling_device_ops structure as const as it is only passed
as an argument to the function thermal_cooling_device_register and this
argument is of type const. So, declare the structure as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/ath/ath10k/thermal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/thermal.c b/drivers/net/wireless/ath/ath10k/thermal.c
index 87948af..ef717b6 100644
--- a/drivers/net/wireless/ath/ath10k/thermal.c
+++ b/drivers/net/wireless/ath/ath10k/thermal.c
@@ -63,7 +63,7 @@ ath10k_thermal_set_cur_throttle_state(struct thermal_cooling_device *cdev,
 	return 0;
 }
 
-static struct thermal_cooling_device_ops ath10k_thermal_ops = {
+static const struct thermal_cooling_device_ops ath10k_thermal_ops = {
 	.get_max_state = ath10k_thermal_get_max_throttle_state,
 	.get_cur_state = ath10k_thermal_get_cur_throttle_state,
 	.set_cur_state = ath10k_thermal_set_cur_throttle_state,
-- 
2.7.4
