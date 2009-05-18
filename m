From: Gabriel Paubert <paubert@iram.es>
Subject: [PATCH v2] Allow selecting mv643xx_eth on Pegasos again
Date: Tue, 19 May 2009 01:21:13 +0200
Message-ID: <20090518232113.GA18469@iram.es>
References: <20090518173756.GA11805@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D323@az33exm24.fsl.freescale.net> <20090518184752.GA12972@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D3A5@az33exm24.fsl.freescale.net> <20090518221847.GA17348@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D459@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, tbm@cyrius.com,
	LinuxPPC <linuxppc-dev@ozlabs.org>, pacman@kosh.dhis.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Medve Emilian-EMMEDVE1 <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gra-lx1.iram.es ([150.214.224.41]:51651 "EHLO gra-lx1.iram.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951AbZERXV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 19:21:28 -0400
Content-Disposition: inline
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E2702C2D459@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since PPC_MUTIPLATFORM was removed, it was impossible to select the
driver for mv643xx_eth on the Pegasos. Fix it and take the opportunity
to remove the stale MV64360 config option.

Signed-off-by: Gabriel Paubert <paubert@iram.es>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..aff4f8c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2351,7 +2351,7 @@ config UGETH_TX_ON_DEMAND
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
+	depends on MV64X60 || PPC32 || PLAT_ORION
 	select INET_LRO
 	select PHYLIB
 	help
