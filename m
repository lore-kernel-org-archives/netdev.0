From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Subject: [PATCH net-next v2] bindings: net: stmmac: add missing note about LPI interrupt
Date: Mon, 10 Apr 2017 09:43:19 +0200
Message-ID: <20170410074320.9506-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>

The hardware has a LPI interrupt.
There is already code in the stmmac driver to parse and handle the
interrupt. However, this information was missing from the DT binding.

Signed-off-by: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index f652b0c384ce..84e4cbfd3b0f 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -8,8 +8,8 @@ Required properties:
   that services interrupts for this device
 - interrupts: Should contain the STMMAC interrupts
 - interrupt-names: Should contain the interrupt names "macirq"
-  "eth_wake_irq" if this interrupt is supported in the "interrupts"
-  property
+  "eth_wake_irq" if this interrupt is supported in the "interrupts" property
+  "eth_lpi" if this interrupt is supported in the "interrupts" property
 - phy-mode: See ethernet.txt file in the same directory.
 - snps,reset-gpio 	gpio number for phy reset.
 - snps,reset-active-low boolean flag to indicate if phy reset is active low.
@@ -152,8 +152,8 @@ Examples:
 		compatible = "st,spear600-gmac";
 		reg = <0xe0800000 0x8000>;
 		interrupt-parent = <&vic1>;
-		interrupts = <24 23>;
-		interrupt-names = "macirq", "eth_wake_irq";
+		interrupts = <24 23 22>;
+		interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
