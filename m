From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 11/11] net/can: allow CAN_AT91 on AT91SAM9X5
Date: Mon,  6 Jun 2011 15:43:00 +0200
Message-ID: <1307367780-30715-12-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48442 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab1FFNnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:43:12 -0400
In-Reply-To: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/Kconfig |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 1d699e3..bbf06f7 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -58,9 +58,10 @@ config CAN_CALC_BITTIMING
=20
 config CAN_AT91
 	tristate "Atmel AT91 onchip CAN controller"
-	depends on CAN_DEV && ARCH_AT91SAM9263
+	depends on CAN_DEV && (ARCH_AT91SAM9263 || ARCH_AT91SAM9X5)
 	---help---
-	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
+	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263
+	  and AT91SAM9X5 processors.
=20
 config CAN_TI_HECC
 	depends on CAN_DEV && ARCH_OMAP3
--=20
1.7.4.1

