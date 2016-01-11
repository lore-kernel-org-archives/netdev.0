From: Marek Vasut <marex@denx.de>
Subject: [PATCH 2/5] net: can: Sort the Makefile
Date: Mon, 11 Jan 2016 19:48:00 +0100
Message-ID: <1452538083-7331-2-git-send-email-marex@denx.de>
References: <1452538083-7331-1-git-send-email-marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marek Vasut <marex@denx.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:35376 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933995AbcAKSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:48:19 -0500
In-Reply-To: <1452538083-7331-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just sort the drivers in the Makefile, no functional change.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/Makefile | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 1f21cef..4f85c2b 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -14,21 +14,21 @@ obj-y				+= spi/
 obj-y				+= usb/
 obj-y				+= softing/
 
-obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
-obj-$(CONFIG_CAN_MSCAN)		+= mscan/
-obj-$(CONFIG_CAN_C_CAN)		+= c_can/
-obj-$(CONFIG_CAN_M_CAN)		+= m_can/
-obj-$(CONFIG_CAN_CC770)		+= cc770/
 obj-$(CONFIG_CAN_AT91)		+= at91_can.o
-obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
-obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
+obj-$(CONFIG_CAN_CC770)		+= cc770/
+obj-$(CONFIG_CAN_C_CAN)		+= c_can/
 obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
-obj-$(CONFIG_PCH_CAN)		+= pch_can.o
 obj-$(CONFIG_CAN_GRCAN)		+= grcan.o
+obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
+obj-$(CONFIG_CAN_MSCAN)		+= mscan/
+obj-$(CONFIG_CAN_M_CAN)		+= m_can/
 obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
+obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_SUN4I)		+= sun4i_can.o
+obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_XILINXCAN)	+= xilinx_can.o
+obj-$(CONFIG_PCH_CAN)		+= pch_can.o
 
 subdir-ccflags-y += -D__CHECK_ENDIAN__
 subdir-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) += -DDEBUG
-- 
2.1.4
