From: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH V2 1/2] stmmac: Add binding document for IMG Pistachio DWMAC
Date: Mon,  6 Apr 2015 14:42:37 -0700
Message-ID: <1428356558-18367-1-git-send-email-abrestic@chromium.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	James Hartley <james.hartley-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a binding document for the DWMAC ethernet controller found on the
IMG Pistachio SoC.

Signed-off-by: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Cc: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: James Hartley <james.hartley-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
---
No changes from v1.
---
 .../devicetree/bindings/net/pistachio-dwmac.txt    | 24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/pistachio-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/pistachio-dwmac.txt b/Documentation/devicetree/bindings/net/pistachio-dwmac.txt
new file mode 100644
index 0000000..9781469
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/pistachio-dwmac.txt
@@ -0,0 +1,24 @@
+IMG Pistachio Ethernet Controller
+=================================
+
+This device is a variant of the DWMAC and inherits the properties described
+in ./stmmac.txt.
+
+Required properties:
+--------------------
+ - compatible: Must contain "img,pistachio-dwmac" and "snps,dwmac".
+ - clocks: Must contain an entry for each entry in clock-names.
+   See ../clock/clock-bindings.txt for details.
+ - clock-names: Must include "stmmaceth" and "sys".
+
+Example:
+--------
+ethernet@18140000 {
+	compatible = "img,pistachio-dwmac";
+	reg = <0x18140000 0x2000>;
+	interrupts = <GIC_SHARED 50 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	clocks = <&clk_core CLK_ENET>, <&cr_periph SYS_CLK_ENET>;
+	clock-names = "stmmaceth", "sys";
+	phy-mode = "rmii";
+};
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
