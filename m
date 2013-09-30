From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 3/3] net: can: c_can_platform: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 09:55:14 +0530
Message-ID: <1380515114-2823-3-git-send-email-sachin.kamat@linaro.org>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The data structure of_match_ptr() protects is always compiled in.
Hence of_match_ptr() is not needed.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org
---
 drivers/net/can/c_can/c_can_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 294ced3..d66ac26 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -322,7 +322,7 @@ static struct platform_driver c_can_plat_driver = {
 	.driver = {
 		.name = KBUILD_MODNAME,
 		.owner = THIS_MODULE,
-		.of_match_table = of_match_ptr(c_can_of_table),
+		.of_match_table = c_can_of_table,
 	},
 	.probe = c_can_plat_probe,
 	.remove = c_can_plat_remove,
-- 
1.7.9.5

