From: Gabriel Paubert <paubert@iram.es>
Subject: [PATCH v3] Remove obsolete MV64360 config option
Date: Tue, 19 May 2009 09:40:45 +0200
Message-ID: <20090519074045.GA27611@iram.es>
References: <20090518221847.GA17348@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D459@az33exm24.fsl.freescale.net> <20090518232113.GA18469@iram.es> <20090518.193549.98339424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emilian.Medve@freescale.com, buytenh@wantstofly.org,
	tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gra-lx1.iram.es ([150.214.224.41]:49722 "EHLO gra-lx1.iram.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753715AbZESHlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 03:41:02 -0400
Content-Disposition: inline
In-Reply-To: <20090518.193549.98339424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gabriel Paubert <paubert@iram.es>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a10e054..570345d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2350,7 +2350,7 @@ config UGETH_TX_ON_DEMAND
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on MV64360 || MV64X60 || PPC32 || PLAT_ORION
+	depends on MV64X60 || PPC32 || PLAT_ORION
 	select INET_LRO
 	select PHYLIB
 	help
