From: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 1/2] devicetree: add binding for Aurora VLSI NB8800 Ethernet controller
Date: Thu, 22 Oct 2015 17:28:49 +0100
Message-ID: <1445531330-17461-1-git-send-email-mans@mansr.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds a binding for the Aurora VLSI NB8800 Ethernet controller
using the "aurora,nb8800" compatible string.  When used in Sigma
Designs chips a few additional control registers are available.
This variant is indicated by the "sigma,smp8640-ethernet" compatible
string.

Signed-off-by: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
---
Changes:
- correct order of compatible strings
---
 .../devicetree/bindings/net/aurora,nb8800.txt      | 26 ++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/aurora,nb8800.txt

diff --git a/Documentation/devicetree/bindings/net/aurora,nb8800.txt b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
new file mode 100644
index 0000000..cf7108d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
@@ -0,0 +1,26 @@
+* Aurora VLSI AU-NB8800 Ethernet controller
+
+Required properties:
+- compatible: Should be "sigma,smp8640-ethernet", "aurora,nb8800"
+	The former indicates presence of extra features added by Sigma Designs.
+- reg: Should be MMIO address space of the device
+- interrupts: Should contain the interrupt specifier for the device
+- interrupt-parent: Should be a phandle for the interrupt controller
+- clocks: Should be a phandle for the clock for the device
+
+Common properties described in ethernet.txt:
+- local-mac-address
+- mac-address
+- max-speed
+- phy-mode
+
+Example:
+
+ethernet@26000 {
+	compatible = "aurora,nb8800";
+	reg = <0x10000 0x800>;
+	interrupts = <42>;
+	clocks = <&sys_clk>;
+	max-speed = <1000>;
+	phy-connection-type = "rgmii";
+};
-- 
2.5.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
