From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 7/7] sfc: Remove 'Communications' after
 'Solarflare' in references to hardware
Date: Thu, 14 Jul 2011 02:18:05 +0100
Message-ID: <1310606285.2756.30.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11366 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab1GNBSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:18:09 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Branding can now be abbreviated.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig |    3 +--
 drivers/net/sfc/efx.c   |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index db7b22e..a3d5bb9 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -7,8 +7,7 @@ config SFC
 	select I2C_ALGOBIT
 	help
 	  This driver supports 10-gigabit Ethernet cards based on
-	  the Solarflare Communications SFC4000 and SFC9000-family
-	  controllers.
+	  the Solarflare SFC4000 and SFC9000-family controllers.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ff162df..faca764 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2476,7 +2476,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		goto fail1;
 
 	netif_info(efx, probe, efx->net_dev,
-		   "Solarflare Communications NIC detected\n");
+		   "Solarflare NIC detected\n");
 
 	/* Set up basic I/O (BAR mappings etc) */
 	rc = efx_init_io(efx);
-- 
1.7.4.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

