From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 6/7] sfc: Remove 'Solarstorm' from Kconfig
 descriptions
Date: Thu, 14 Jul 2011 02:17:49 +0100
Message-ID: <1310606269.2756.29.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11326 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1GNBRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:17:52 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'Solarstorm' brand is being retired and it's redundant with the
company name.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index a65c986..db7b22e 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -1,5 +1,5 @@
 config SFC
-	tristate "Solarflare Solarstorm SFC4000/SFC9000-family support"
+	tristate "Solarflare SFC4000/SFC9000-family support"
 	depends on PCI && INET
 	select MDIO
 	select CRC32
@@ -7,13 +7,13 @@ config SFC
 	select I2C_ALGOBIT
 	help
 	  This driver supports 10-gigabit Ethernet cards based on
-	  the Solarflare Communications Solarstorm SFC4000 and
-	  SFC9000-family controllers.
+	  the Solarflare Communications SFC4000 and SFC9000-family
+	  controllers.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
 config SFC_MTD
-	bool "Solarflare Solarstorm SFC4000/SFC9000-family MTD support"
+	bool "Solarflare SFC4000/SFC9000-family MTD support"
 	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	help
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

