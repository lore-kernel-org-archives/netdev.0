From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v6] net: ethernet: xilinx: Enable emaclite for MIPS
Date: Mon, 5 Sep 2016 13:07:54 +0100
Message-ID: <1473077274-63160-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <michal.simek@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Zubair.Kakakhel@imgtec.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MIPS based xilfpga platform uses this driver.
Enable it for MIPS

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V1 -> V6 are from a series that has gotten too big.
So I have split this patch and am sending it separately.
---
 drivers/net/ethernet/xilinx/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 4f5c024..6d68c8a 100644
--- a/drivers/net/ethernet/xilinx/Kconfig
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_XILINX
 	bool "Xilinx devices"
 	default y
-	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ
+	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ || MIPS
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
@@ -18,7 +18,7 @@ if NET_VENDOR_XILINX
 
 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
-	depends on (PPC32 || MICROBLAZE || ARCH_ZYNQ)
+	depends on PPC32 || MICROBLAZE || ARCH_ZYNQ || MIPS
 	select PHYLIB
 	---help---
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
-- 
1.9.1
