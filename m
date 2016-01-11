From: Marek Vasut <marex@denx.de>
Subject: [PATCH 1/5] net: can: Sort the Kconfig includes
Date: Mon, 11 Jan 2016 19:47:59 +0100
Message-ID: <1452538083-7331-1-git-send-email-marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marek Vasut <marex@denx.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38247 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933221AbcAKSsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:48:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sort the Kconfig includes, no functional change.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/Kconfig | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 6d04183..ca49d15 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -147,22 +147,22 @@ config CAN_XILINXCAN
 	  Xilinx CAN driver. This driver supports both soft AXI CAN IP and
 	  Zynq CANPS IP.
 
-source "drivers/net/can/mscan/Kconfig"
-
-source "drivers/net/can/sja1000/Kconfig"
-
 source "drivers/net/can/c_can/Kconfig"
 
+source "drivers/net/can/cc770/Kconfig"
+
 source "drivers/net/can/m_can/Kconfig"
 
-source "drivers/net/can/cc770/Kconfig"
+source "drivers/net/can/mscan/Kconfig"
+
+source "drivers/net/can/sja1000/Kconfig"
+
+source "drivers/net/can/softing/Kconfig"
 
 source "drivers/net/can/spi/Kconfig"
 
 source "drivers/net/can/usb/Kconfig"
 
-source "drivers/net/can/softing/Kconfig"
-
 endif
 
 config CAN_DEBUG_DEVICES
-- 
2.1.4
