From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/phy/Kconfig: Let MDIO_BCM_UNIMAC depend on HAS_IOMEM
Date: Sat, 04 Oct 2014 17:54:33 +0800
Message-ID: <542FC3D9.4080607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard@nod.at
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MDIO_BCM_UNIMAC needs HAS_IOMEM, so depend on it, the related error (
with allmodconfig under um):

    MODPOST 1205 modules
  ERROR: "devm_ioremap" [drivers/net/phy/mdio-bcm-unimac.ko] undefined!

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/phy/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 14afa4f..75472cf7 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -205,6 +205,7 @@ config MDIO_BUS_MUX_MMIOREG
 
 config MDIO_BCM_UNIMAC
 	tristate "Broadcom UniMAC MDIO bus controller"
+	depends on HAS_IOMEM
 	help
 	  This module provides a driver for the Broadcom UniMAC MDIO busses.
 	  This hardware can be found in the Broadcom GENET Ethernet MAC
-- 
1.9.3
