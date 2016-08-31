From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v3 09/11] net: ethernet: xilinx: Enable emaclite for MIPS
Date: Wed, 31 Aug 2016 17:35:50 +0100
Message-ID: <1472661352-11983-10-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <soren.brinkmann@xilinx.com>, <Zubair.Kakakhel@imgtec.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <michal.simek@xilinx.com>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:20113 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965120AbcHaQhG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:37:06 -0400
In-Reply-To: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MIPS based xilfpga platform uses this driver.
Enable it for MIPS

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V2 -> V3
No change

V1 -> V2

No change
---
 drivers/net/ethernet/xilinx/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 4f5c024..ae5c404 100644
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
+	depends on (PPC32 || MICROBLAZE || ARCH_ZYNQ || MIPS)
 	select PHYLIB
 	---help---
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
-- 
1.9.1
