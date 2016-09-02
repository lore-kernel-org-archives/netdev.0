From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v5 2/2] net: ethernet: xilinx: Enable emaclite for MIPS
Date: Fri, 2 Sep 2016 12:39:26 +0100
Message-ID: <1472816366-1018-3-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <Zubair.Kakakhel@imgtec.com>
To: <davem@davemloft.net>, <michal.simek@xilinx.com>,
        <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MIPS based xilfpga platform uses this driver.
Enable it for MIPS

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V3 -> V4
Removed unnecesary braces

V2 -> V3
No change

V1 -> V2

No change
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
