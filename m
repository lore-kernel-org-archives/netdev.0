From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 12/16 linux-next] can: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:24 +0100
Message-ID: <1426617628-937-3-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/can/cc770/cc770_platform.c     | 2 +-
 drivers/net/can/grcan.c                    | 2 +-
 drivers/net/can/mscan/mpc5xxx_can.c        | 2 +-
 drivers/net/can/sja1000/sja1000_platform.c | 2 +-
 drivers/net/can/xilinx_can.c               | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index b1e8851..866e5e1 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -254,7 +254,7 @@ static int cc770_platform_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id cc770_platform_table[] = {
+static const struct of_device_id cc770_platform_table[] = {
 	{.compatible = "bosch,cc770"}, /* CC770 from Bosch */
 	{.compatible = "intc,82527"},  /* AN82527 from Intel CP */
 	{},
diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index fed1bbd..e3d7e22 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1725,7 +1725,7 @@ static int grcan_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id grcan_match[] = {
+static const struct of_device_id grcan_match[] = {
 	{.name = "GAISLER_GRCAN"},
 	{.name = "01_03d"},
 	{.name = "GAISLER_GRHCAN"},
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index ad024e6..c7427bd 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -43,7 +43,7 @@ struct mpc5xxx_can_data {
 };
 
 #ifdef CONFIG_PPC_MPC52xx
-static struct of_device_id mpc52xx_cdm_ids[] = {
+static const struct of_device_id mpc52xx_cdm_ids[] = {
 	{ .compatible = "fsl,mpc5200-cdm", },
 	{}
 };
diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 9311525..0552ed4 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -242,7 +242,7 @@ static int sp_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id sp_of_table[] = {
+static const struct of_device_id sp_of_table[] = {
 	{.compatible = "nxp,sja1000"},
 	{},
 };
diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 6c67643..6bddfe0 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -1185,7 +1185,7 @@ static int xcan_remove(struct platform_device *pdev)
 }
 
 /* Match table for OF platform binding */
-static struct of_device_id xcan_of_match[] = {
+static const struct of_device_id xcan_of_match[] = {
 	{ .compatible = "xlnx,zynq-can-1.0", },
 	{ .compatible = "xlnx,axi-can-1.00.a", },
 	{ /* end of list */ },
-- 
2.1.0

