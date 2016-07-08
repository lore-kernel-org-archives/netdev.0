From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] ARM: dts: NSP: Add Switch Register Access Block node
Date: Fri,  8 Jul 2016 11:49:28 -0700
Message-ID: <1468003769-26959-2-git-send-email-f.fainelli@gmail.com>
References: <1468003769-26959-1-git-send-email-f.fainelli@gmail.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468003769-26959-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the Switch Register Access Block node, this peripheral is identical
to the BCM5301x Northstar SoC, but we utilize the SoC-wide
"brcm,nsp-srab" compatible string to illustrate the integration
difference here.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/arm/boot/dts/bcm-nsp.dtsi | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
index 8d7b35a4b5f1..983fdba905e3 100644
--- a/arch/arm/boot/dts/bcm-nsp.dtsi
+++ b/arch/arm/boot/dts/bcm-nsp.dtsi
@@ -241,6 +241,17 @@
 			clock-names = "apb_pclk";
 		};
 
+		srab: srab@36000 {
+			compatible = "brcm,nsp-srab";
+			reg = <0x36000 0x1000>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			status = "disabled";
+
+			/* ports are defined in board DTS */
+		};
+
 		i2c0: i2c@38000 {
 			compatible = "brcm,iproc-i2c";
 			reg = <0x38000 0x50>;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
