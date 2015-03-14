From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] net: can: Enable xilinx driver for ARM64
Date: Sat, 14 Mar 2015 15:17:18 +0100
Message-ID: <1426342639-14894-2-git-send-email-mkl@pengutronix.de>
References: <1426342639-14894-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Michal Simek <michal.simek@xilinx.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38641 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbbCNORZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 10:17:25 -0400
In-Reply-To: <1426342639-14894-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Simek <michal.simek@xilinx.com>

Enable the xilinx driver for ARM64.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 98d73aab52fe..58808f651452 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -131,7 +131,7 @@ config CAN_RCAR
=20
 config CAN_XILINXCAN
 	tristate "Xilinx CAN"
-	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
+	depends on ARCH_ZYNQ || ARM64 || MICROBLAZE || COMPILE_TEST
 	depends on COMMON_CLK && HAS_IOMEM
 	---help---
 	  Xilinx CAN driver. This driver supports both soft AXI CAN IP and
--=20
2.1.4
