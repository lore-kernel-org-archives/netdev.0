From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/17] can: dev: fix typo CIA -> CiA, CAN in Automation
Date: Tue, 18 Nov 2014 21:37:32 +0100
Message-ID: <1416343067-9810-3-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Roman Fietze <roman.fietze@telemotive.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roman Fietze <roman.fietze@telemotive.de>

This patch fixes a typo in CAN's dev.c:

    CIA -> CiA

which stands for CAN in Automation.

Signed-off-by: Roman Fietze <roman.fietze@telemotive.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 509d5e063d8c..2cfe5012e4e5 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -110,7 +110,7 @@ static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt,
 	long rate;
 	u64 v64;
 
-	/* Use CIA recommended sample points */
+	/* Use CiA recommended sample points */
 	if (bt->sample_point) {
 		sampl_pt = bt->sample_point;
 	} else {
-- 
2.1.3

