From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 2/3] net: phy: MDIO_BCM_UNIMAC should depend on OF_MDIO
Date: Thu, 23 Mar 2017 10:01:18 -0700
Message-ID: <20170323170119.4004-3-f.fainelli@gmail.com>
References: <20170323170119.4004-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        arnd@arndb.de, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:33655 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755864AbdCWRB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:01:28 -0400
Received: by mail-ot0-f196.google.com with SMTP id i50so20077065otd.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:01:27 -0700 (PDT)
In-Reply-To: <20170323170119.4004-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom MDIO UniMAC driver uses routines provided by of_mdio.c which is
guarded by CONFIG_OF_MDIO.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8dbd59baa34d..7ab4b14a43b7 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -40,7 +40,7 @@ config MDIO_BCM_IPROC
 
 config MDIO_BCM_UNIMAC
 	tristate "Broadcom UniMAC MDIO bus controller"
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && OF_MDIO
 	help
 	  This module provides a driver for the Broadcom UniMAC MDIO busses.
 	  This hardware can be found in the Broadcom GENET Ethernet MAC
-- 
2.9.3
