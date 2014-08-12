From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Subject: [PATCH] ath6kl: Add SDIO device ID for QCA6234X Support
Date: Tue, 12 Aug 2014 11:45:59 +0100
Message-ID: <1407840359-6658-1-git-send-email-srinivas.kandadgatla@linaro.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>

This patch adds device ID 402 to support QCA6234X found in APQ8064 SOC
in IFC6410 board.

Tested with mainline mmci sdio driver.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
---
 drivers/net/wireless/ath/ath6kl/sdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wireless/ath/ath6kl/sdio.c
index 339d89f..eab0ab9 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -1400,6 +1400,7 @@ static const struct sdio_device_id ath6kl_sdio_devices[] = {
 	{SDIO_DEVICE(MANUFACTURER_CODE, (MANUFACTURER_ID_AR6003_BASE | 0x1))},
 	{SDIO_DEVICE(MANUFACTURER_CODE, (MANUFACTURER_ID_AR6004_BASE | 0x0))},
 	{SDIO_DEVICE(MANUFACTURER_CODE, (MANUFACTURER_ID_AR6004_BASE | 0x1))},
+	{SDIO_DEVICE(MANUFACTURER_CODE, (MANUFACTURER_ID_AR6004_BASE | 0x2))},
 	{},
 };
 
-- 
1.9.1
