From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] can: flexcan: demote register output to debug level
Date: Fri,  7 Aug 2015 17:16:03 +0200
Message-ID: <1438960563-17905-1-git-send-email-l.stach@pengutronix.de>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	patchwork-lst@pengutronix.de
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message isn't really helpful for the general reader of the kernel
logs, so should not be printed with info level. All other register
programming outputs in the flexcan driver already use the debug level.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ad0a7e8c2c2b..95abd395cb0d 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -797,7 +797,7 @@ static void flexcan_set_bittiming(struct net_device *dev)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
 		reg |= FLEXCAN_CTRL_SMP;
 
-	netdev_info(dev, "writing ctrl=0x%08x\n", reg);
+	netdev_dbg(dev, "writing ctrl=0x%08x\n", reg);
 	flexcan_write(reg, &regs->ctrl);
 
 	/* print chip status */
-- 
2.4.6

