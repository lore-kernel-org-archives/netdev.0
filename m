From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 2/3] ARM: dts: k2g: Add DCAN nodes
Date: Wed, 2 Aug 2017 15:18:21 -0500
Message-ID: <20170802201822.11532-3-fcooper@ti.com>
References: <20170802201822.11532-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lokesh Vutla <lokeshvutla@ti.com>, Dave Gerlach <d-gerlach@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <ssantosh@kernel.org>, <linux@armlinux.org.uk>,
        <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802201822.11532-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lokesh Vutla <lokeshvutla@ti.com>

Add nodes for the two DCAN instances included in 66AK2G

Signed-off-by: Lokesh Vutla <lokeshvutla@ti.com>
[d-gerlach@ti.com: add power-domains and clock information]
Signed-off-by: Dave Gerlach <d-gerlach@ti.com>
[fcooper@ti.com: update subject and commit message. Misc minor updates]
Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 arch/arm/boot/dts/keystone-k2g.dtsi | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/arm/boot/dts/keystone-k2g.dtsi b/arch/arm/boot/dts/keystone-k2g.dtsi
index bf4d1fa..bebc857 100644
--- a/arch/arm/boot/dts/keystone-k2g.dtsi
+++ b/arch/arm/boot/dts/keystone-k2g.dtsi
@@ -113,6 +113,24 @@
 			status = "disabled";
 		};
 
+		dcan0: can@0260B200 {
+			compatible = "ti,am4372-d_can", "ti,am3352-d_can";
+			reg = <0x0260B200 0x200>;
+			interrupts = <GIC_SPI 190 IRQ_TYPE_EDGE_RISING>;
+			status = "disabled";
+			power-domains = <&k2g_pds 0x0008>;
+			clocks = <&k2g_clks 0x0008 1>;
+		};
+
+		dcan1: can@0260B400 {
+			compatible = "ti,am4372-d_can", "ti,am3352-d_can";
+			reg = <0x0260B400 0x200>;
+			interrupts = <GIC_SPI 193 IRQ_TYPE_EDGE_RISING>;
+			status = "disabled";
+			power-domains = <&k2g_pds 0x0009>;
+			clocks = <&k2g_clks 0x0009 1>;
+		};
+
 		kirq0: keystone_irq@026202a0 {
 			compatible = "ti,keystone-irq";
 			interrupts = <GIC_SPI 1 IRQ_TYPE_EDGE_RISING>;
-- 
2.9.4.dirty
