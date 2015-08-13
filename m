From: Stuart Yoder <stuart.yoder@freescale.com>
Subject: [PATCH] net/fsl: simplify Kconfig dependency list for fsl networking
Date: Thu, 13 Aug 2015 17:01:59 -0500
Message-ID: <1439503319-25453-1-git-send-email-stuart.yoder@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<scottwood@freescale.com>,
	Stuart Yoder <stuart.yoder@freescale.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make the list of Kconfig dependencies for Freescale
networking more general. Simplify to supported
architectures: ARM, ARM64, PPC, M68K

Signed-off-by: Stuart Yoder <stuart.yoder@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index ff76d4e..70782d7 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -5,9 +5,7 @@
 config NET_VENDOR_FREESCALE
 	bool "Freescale devices"
 	default y
-	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
-		   M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
+	depends on M68K || PPC || ARM || ARM64
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
-- 
2.3.3
