From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: can: at91_can: Use of_match_ptr()
Date: Wed, 12 Jun 2013 17:00:39 +0530
Message-ID: <1371036639-16798-1-git-send-email-sachin.kamat@linaro.org>
Cc: linux-can@vger.kernel.org, davem@davemloft.net, wg@grandegger.com,
	sachin.kamat@linaro.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_match_ptr() eliminates having an #ifdef returning NULL for the case
when OF is disabled.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index ce8421a..dbbe97a 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1264,8 +1264,6 @@ static const struct of_device_id at91_can_dt_ids[] = {
 	}
 };
 MODULE_DEVICE_TABLE(of, at91_can_dt_ids);
-#else
-#define at91_can_dt_ids NULL
 #endif
 
 static const struct at91_devtype_data *at91_can_get_driver_data(struct platform_device *pdev)
@@ -1424,7 +1422,7 @@ static struct platform_driver at91_can_driver = {
 	.driver = {
 		.name = KBUILD_MODNAME,
 		.owner = THIS_MODULE,
-		.of_match_table = at91_can_dt_ids,
+		.of_match_table = of_match_ptr(at91_can_dt_ids),
 	},
 	.id_table = at91_can_id_table,
 };
-- 
1.7.9.5

