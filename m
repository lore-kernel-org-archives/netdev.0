From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 379/493] net: remove use of __devinitconst
Date: Mon, 19 Nov 2012 13:25:28 -0500
Message-ID: <1353349642-3677-379-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41484 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab2KSSer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:47 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitconst is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com> 
Cc: Marc Kleine-Budde <mkl@pengutronix.de> 
Cc: Luciano Coelho <coelho@ti.com> 
Cc: "John W. Linville" <linville@tuxdriver.com> 
Cc: linux-can@vger.kernel.org 
Cc: netdev@vger.kernel.org 
Cc: linux-wireless@vger.kernel.org 
---
 drivers/net/can/at91_can.c            | 2 +-
 drivers/net/can/mscan/mpc5xxx_can.c   | 6 +++---
 drivers/net/can/sja1000/tscan1.c      | 2 +-
 drivers/net/wireless/ti/wl12xx/main.c | 2 +-
 drivers/net/wireless/ti/wl18xx/main.c | 2 +-
 drivers/net/wireless/ti/wlcore/sdio.c | 2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 32e60dd..da807f3 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -154,7 +154,7 @@ struct at91_priv {
 	canid_t mb0_id;
 };
 
-static const struct at91_devtype_data at91_devtype_data[] __devinitconst = {
+static const struct at91_devtype_data at91_devtype_data[] = {
 	[AT91_DEVTYPE_SAM9263] = {
 		.rx_first = 1,
 		.rx_split = 8,
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 254c168..508cbad 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -380,17 +380,17 @@ static int mpc5xxx_can_resume(struct platform_device *ofdev)
 }
 #endif
 
-static const struct mpc5xxx_can_data __devinitconst mpc5200_can_data = {
+static const struct mpc5xxx_can_data mpc5200_can_data = {
 	.type = MSCAN_TYPE_MPC5200,
 	.get_clock = mpc52xx_can_get_clock,
 };
 
-static const struct mpc5xxx_can_data __devinitconst mpc5121_can_data = {
+static const struct mpc5xxx_can_data mpc5121_can_data = {
 	.type = MSCAN_TYPE_MPC5121,
 	.get_clock = mpc512x_can_get_clock,
 };
 
-static const struct of_device_id __devinitconst mpc5xxx_can_table[] = {
+static const struct of_device_id mpc5xxx_can_table[] = {
 	{ .compatible = "fsl,mpc5200-mscan", .data = &mpc5200_can_data, },
 	/* Note that only MPC5121 Rev. 2 (and later) is supported */
 	{ .compatible = "fsl,mpc5121-mscan", .data = &mpc5121_can_data, },
diff --git a/drivers/net/can/sja1000/tscan1.c b/drivers/net/can/sja1000/tscan1.c
index 9b608d8..6a6db7e 100644
--- a/drivers/net/can/sja1000/tscan1.c
+++ b/drivers/net/can/sja1000/tscan1.c
@@ -71,7 +71,7 @@ MODULE_LICENSE("GPL");
 #define TSCAN1_SJA1000_XTAL 16000000
 
 /* SJA1000 IO base addresses */
-static const unsigned short tscan1_sja1000_addresses[] __devinitconst = {
+static const unsigned short tscan1_sja1000_addresses[] = {
 	0x100, 0x120, 0x180, 0x1a0, 0x200, 0x240, 0x280, 0x320
 };
 
diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
index c10e691..e5f5f8f 100644
--- a/drivers/net/wireless/ti/wl12xx/main.c
+++ b/drivers/net/wireless/ti/wl12xx/main.c
@@ -1725,7 +1725,7 @@ out:
 	return ret;
 }
 
-static const struct platform_device_id wl12xx_id_table[] __devinitconst = {
+static const struct platform_device_id wl12xx_id_table[] = {
 	{ "wl12xx", 0 },
 	{  } /* Terminating Entry */
 };
diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index 7171c93..8d8c1f8 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -1528,7 +1528,7 @@ out:
 	return ret;
 }
 
-static const struct platform_device_id wl18xx_id_table[] __devinitconst = {
+static const struct platform_device_id wl18xx_id_table[] = {
 	{ "wl18xx", 0 },
 	{  } /* Terminating Entry */
 };
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 6fa2a01..7bf612c 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -54,7 +54,7 @@ struct wl12xx_sdio_glue {
 	struct platform_device *core;
 };
 
-static const struct sdio_device_id wl1271_devices[] __devinitconst = {
+static const struct sdio_device_id wl1271_devices[] = {
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_TI, SDIO_DEVICE_ID_TI_WL1271) },
 	{}
 };
-- 
1.8.0
