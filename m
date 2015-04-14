From: Daniel Axtens <dja@axtens.net>
Subject: [PATCH v2 1/3] toshiba: Remove celleb from Kconfig options
Date: Tue, 14 Apr 2015 15:28:44 +1000
Message-ID: <1428989326-7637-1-git-send-email-dja@axtens.net>
Cc: Daniel Axtens <dja@axtens.net>, netdev@vger.kernel.org,
	Valentin Rothberg <valentinrothberg@gmail.com>,
	mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The toshiba drivers had celleb as an optional dependency.
celleb has been dropped [1], so clean that out of Kconfig.

[1] http://patchwork.ozlabs.org/patch/451730/

CC: netdev@vger.kernel.org
CC: Valentin Rothberg <valentinrothberg@gmail.com>
CC: mpe@ellerman.id.au
CC: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Daniel Axtens <dja@axtens.net>

---
v2: get name of ozlab*s*.org right. Sorry all.
---
 drivers/net/ethernet/toshiba/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/Kconfig b/drivers/net/ethernet/toshiba/Kconfig
index 74acb5c..5d244b6 100644
--- a/drivers/net/ethernet/toshiba/Kconfig
+++ b/drivers/net/ethernet/toshiba/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_TOSHIBA
 	bool "Toshiba devices"
 	default y
-	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB || MIPS) || PPC_PS3
+	depends on PCI && (PPC_IBM_CELL_BLADE || MIPS) || PPC_PS3
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -42,7 +42,7 @@ config GELIC_WIRELESS
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
+	depends on PCI && PPC_IBM_CELL_BLADE
 	select FW_LOADER
 	select SUNGEM_PHY
 	---help---
-- 
2.1.4
