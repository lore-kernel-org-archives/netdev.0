From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] ARM: dts: BCM5301X: Add SRAB interrupts
Date: Fri,  8 Jul 2016 11:48:53 -0700
Message-ID: <1468003735-26895-4-git-send-email-f.fainelli@gmail.com>
References: <1468003735-26895-1-git-send-email-f.fainelli@gmail.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468003735-26895-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add interrupt mapping for the Switch Register Access Block. Only 12
interrupts are usable at the moment even though up to 32 are dedicated
to the SRAB.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/arm/boot/dts/bcm5301x.dtsi | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/arch/arm/boot/dts/bcm5301x.dtsi b/arch/arm/boot/dts/bcm5301x.dtsi
index 9fb565841004..a20ebd2ac9a2 100644
--- a/arch/arm/boot/dts/bcm5301x.dtsi
+++ b/arch/arm/boot/dts/bcm5301x.dtsi
@@ -153,6 +153,21 @@
 			/* ChipCommon */
 			<0x00000000 0 &gic GIC_SPI 85 IRQ_TYPE_LEVEL_HIGH>,
 
+			/* Switch Register Access Block */
+			<0x00007000 0 &gic GIC_SPI 95 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 1 &gic GIC_SPI 96 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 2 &gic GIC_SPI 97 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 3 &gic GIC_SPI 98 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 4 &gic GIC_SPI 99 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 5 &gic GIC_SPI 100 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 6 &gic GIC_SPI 101 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 7 &gic GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 8 &gic GIC_SPI 103 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 9 &gic GIC_SPI 104 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 10 &gic GIC_SPI 105 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 11 &gic GIC_SPI 106 IRQ_TYPE_LEVEL_HIGH>,
+			<0x00007000 12 &gic GIC_SPI 107 IRQ_TYPE_LEVEL_HIGH>,
+
 			/* PCIe Controller 0 */
 			<0x00012000 0 &gic GIC_SPI 126 IRQ_TYPE_LEVEL_HIGH>,
 			<0x00012000 1 &gic GIC_SPI 127 IRQ_TYPE_LEVEL_HIGH>,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
