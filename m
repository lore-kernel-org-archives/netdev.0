From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] dt-bindings: net: Remove duplicate NSP Ethernet MAC binding document
Date: Sat, 15 Jul 2017 10:24:47 -0700
Message-ID: <20170715172450.22162-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 07d4510f5251 ("dt-bindings: net: bgmac: add bindings documentation for
bgmac") added both brcm,amac-nsp.txt and brcm,bgmac-nsp.txt. The former is
actually the one that got updated and is in use by the bgmac driver while the
latter is duplicating the former and is not used nor updated.

Fixes: 07d4510f5251 ("dt-bindings: net: bgmac: add bindings documentation for bgmac")
Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 .../devicetree/bindings/net/brcm,bgmac-nsp.txt     | 24 ----------------------
 1 file changed, 24 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
deleted file mode 100644
index 022946caa7e2..000000000000
--- a/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
+++ /dev/null
@@ -1,24 +0,0 @@
-Broadcom GMAC Ethernet Controller Device Tree Bindings
--------------------------------------------------------------
-
-Required properties:
- - compatible:	"brcm,bgmac-nsp"
- - reg:		Address and length of the GMAC registers,
-		Address and length of the GMAC IDM registers
- - reg-names:	Names of the registers.  Must have both "gmac_base" and
-		"idm_base"
- - interrupts:	Interrupt number
-
-Optional properties:
-- mac-address:	See ethernet.txt file in the same directory
-
-Examples:
-
-gmac0: ethernet@18022000 {
-	compatible = "brcm,bgmac-nsp";
-	reg = <0x18022000 0x1000>,
-	      <0x18110000 0x1000>;
-	reg-names = "gmac_base", "idm_base";
-	interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
-	status = "disabled";
-};
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
