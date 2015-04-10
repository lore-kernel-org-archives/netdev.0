From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH 1/3] devicetree: Add compatible string for Zynq Ultrascale MPSoC
Date: Fri, 10 Apr 2015 14:47:19 +0530
Message-ID: <ab4bdff5-a868-4dc0-820e-c338d149f7a8@BN1AFFO11FD053.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add "cdns,zynqmp-gem" to be used for Zynq Ultrascal MPSoc.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 Documentation/devicetree/bindings/net/macb.txt |    1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index ba19d67..a112add 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -9,6 +9,7 @@ Required properties:
   the Cadence GEM, or the generic form: "cdns,gem".
   Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
   Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
+  Use "cdns,zynqmp-gem" for Zynq Ultrascale MPSoC.
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
 - phy-mode: See ethernet.txt file in the same directory.
-- 
1.7.9.5
