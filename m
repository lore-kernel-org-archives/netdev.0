From: Peter Robinson <pbrobinson@gmail.com>
Subject: [PATCH 2/2] net:phy:hisi: Depend on the appropraite SoC
Date: Sun,  5 Mar 2017 12:14:34 +0000
Message-ID: <20170305121434.22674-3-pbrobinson@gmail.com>
References: <20170305121434.22674-1-pbrobinson@gmail.com>
Cc: Peter Robinson <pbrobinson@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34250 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdCEMOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:14:51 -0500
Received: by mail-wm0-f68.google.com with SMTP id u132so1566526wmg.1
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 04:14:50 -0800 (PST)
In-Reply-To: <20170305121434.22674-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HiSi PHY only ships on the ARM SoC so depend on it.

Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
---
 drivers/net/phy/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 59b8313..be6f853 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -113,6 +113,7 @@ config MDIO_GPIO
 
 config MDIO_HISI_FEMAC
 	tristate "Hisilicon FEMAC MDIO bus controller"
+	depends on ARCH_HISI || COMPILE_TEST
 	depends on HAS_IOMEM && OF_MDIO
 	help
 	  This module provides a driver for the MDIO busses found in the
-- 
2.9.3
