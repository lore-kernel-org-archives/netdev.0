From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH 1/2] mv643xx_eth: restrict to 32-bit PPC_MULTIPLATFORM
Date: Wed, 20 Sep 2006 12:24:34 -0700
Message-ID: <20060920192434.GA13293@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:43532 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S932298AbWITTY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 15:24:29 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

No 64-bit PPC_MULTIPLATFORM platforms use the mv643xx_eth driver,
so build it only on PPC32.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
Acked-by: Sven Luther <sl@bplan-gmbh.de>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a2bd811..2154ae2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2262,7 +2262,7 @@ config UGETH_HAS_GIGA
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3 || PPC_MULTIPLATFORM
+	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3 || (PPC_MULTIPLATFORM && PPC32)
 	select MII
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
