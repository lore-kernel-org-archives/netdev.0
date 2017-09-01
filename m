From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 3/5] net: mdio-mux: printing driver version is useless
Date: Fri,  1 Sep 2017 13:56:02 +0200
Message-ID: <20170901115604.27513-4-clabbe.montjoie@gmail.com>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the driver version information because this information
is not useful in an upstream kernel driver.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/phy/mdio-mux.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 5e08e89465c5..282828551bdd 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 
-#define DRV_VERSION "1.0"
 #define DRV_DESCRIPTION "MDIO bus multiplexer driver"
 
 struct mdio_mux_child_bus;
@@ -179,7 +178,6 @@ int mdio_mux_init(struct device *dev,
 	}
 	if (pb->children) {
 		*mux_handle = pb;
-		dev_info(dev, "Version " DRV_VERSION "\n");
 		return 0;
 	}
 
@@ -212,6 +210,5 @@ void mdio_mux_uninit(void *mux_handle)
 EXPORT_SYMBOL_GPL(mdio_mux_uninit);
 
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
-MODULE_VERSION(DRV_VERSION);
 MODULE_AUTHOR("David Daney");
 MODULE_LICENSE("GPL");
-- 
2.13.5
