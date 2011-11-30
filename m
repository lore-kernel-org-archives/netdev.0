From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH v2] net: fec: Select the FEC driver by default for i.MX SoCs
Date: Wed, 30 Nov 2011 09:31:57 -0200
Message-ID: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel@pengutronix.de>, <shawn.guo@freescale.com>,
	<u.kleine-koenig@pengutronix.de>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <marek.vasut@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:33198
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807Ab1K3LcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 06:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let the FEC driver be built by default.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1: 
Move the FEC selection into Kconfig instead of .config file

 drivers/net/ethernet/freescale/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index c520cfd..ae269ad 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -22,6 +22,7 @@ if NET_VENDOR_FREESCALE
 
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	default ARCH_MXC || ARCH_MXS if ARM
 	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   ARCH_MXC || ARCH_MXS)
 	select PHYLIB
-- 
1.7.1
