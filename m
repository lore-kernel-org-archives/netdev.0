From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 4/5] net: mdio-mux-mmioreg: Can handle 8/16/32 bits registers
Date: Fri,  1 Sep 2017 13:56:03 +0200
Message-ID: <20170901115604.27513-5-clabbe.montjoie@gmail.com>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix an old information that mdio-mux-mmioreg can only handle
8bit registers.
This is not true anymore.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5afe6fdcc968..a9d16a3af514 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -85,7 +85,7 @@ config MDIO_BUS_MUX_MMIOREG
 	  parent bus.  Child bus selection is under the control of one of
 	  the FPGA's registers.
 
-	  Currently, only 8-bit registers are supported.
+	  Currently, only 8/16/32 bits registers are supported.
 
 config MDIO_CAVIUM
 	tristate
-- 
2.13.5
