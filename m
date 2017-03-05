From: Peter Robinson <pbrobinson@gmail.com>
Subject: [PATCH 1/2] net: phy: Add dependencies for Cavium SoCs
Date: Sun,  5 Mar 2017 12:14:33 +0000
Message-ID: <20170305121434.22674-2-pbrobinson@gmail.com>
References: <20170305121434.22674-1-pbrobinson@gmail.com>
Cc: Peter Robinson <pbrobinson@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33962 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdCEMOo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:14:44 -0500
Received: by mail-wr0-f195.google.com with SMTP id u48so18475766wrc.1
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 04:14:43 -0800 (PST)
In-Reply-To: <20170305121434.22674-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dependencies on the Cavium architectures for the PHYs
as well as COMPILE_TEST to ensure build coverage.

Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
---
 drivers/net/phy/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8dbd59b..59b8313 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -127,7 +127,7 @@ config MDIO_MOXART
 
 config MDIO_OCTEON
 	tristate "Octeon and some ThunderX SOCs MDIO buses"
-	depends on 64BIT
+	depends on CAVIUM_OCTEON_SOC || ARCH_THUNDER || COMPILE_TEST
 	depends on HAS_IOMEM
 	select MDIO_CAVIUM
 	help
@@ -145,7 +145,7 @@ config MDIO_SUN4I
 
 config MDIO_THUNDER
 	tristate "ThunderX SOCs MDIO buses"
-	depends on 64BIT
+	depends on ARCH_THUNDER || COMPILE_TEST
 	depends on PCI
 	select MDIO_CAVIUM
 	help
-- 
2.9.3
