From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 2/2] [RFC] don't let BCM63XX_PHY depend on non-existant symbol
Date: Mon,  4 Oct 2010 11:43:33 +0200
Message-ID: <1286185413-22924-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maxime Bizon <mbizon@freebox.fr>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52077 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab0JDJnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 05:43:43 -0400
In-Reply-To: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel doesn't have a symbol called BCM63XX.  There is a symbol
BCM63XX_ENET (introduced in 9b1fc55a0500, 6 weeks after 09bb9aa0ed that
introduced BCM63XX_PHY), but the driver compiles without that, too.

Cc: Maxime Bizon <mbizon@freebox.fr>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/phy/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index eb799b3..cb3d13e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -58,7 +58,6 @@ config BROADCOM_PHY
=20
 config BCM63XX_PHY
 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
-	depends on BCM63XX
 	---help---
 	  Currently supports the 6348 and 6358 PHYs.
=20
--=20
1.7.2.3

