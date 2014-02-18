From: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] net: ethoc: document OF bindings
Date: Wed, 19 Feb 2014 02:46:50 +0400
Message-ID: <1392763610-19197-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changes v1->v2:
- drop local-mac-address optional property description
  (described in the common ethernet.txt);
- drop optional properties for MDIO bus frequency and MAC frequency
  (removed from the implementation);
- add clocks property.

 .../devicetree/bindings/net/opencores-ethoc.txt    | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/opencores-ethoc.txt

diff --git a/Documentation/devicetree/bindings/net/opencores-ethoc.txt b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
new file mode 100644
index 0000000..41e2675
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
@@ -0,0 +1,22 @@
+* OpenCores MAC 10/100 Mbps
+
+Required properties:
+- compatible: Should be "opencores,ethoc".
+- reg: two memory regions (address and length),
+  first region is for the device registers and descriptor rings,
+  second is for the device packet memory.
+- interrupts: interrupt for the device.
+
+Optional properties:
+- clocks: phandle to refer to the clk used as per
+  Documentation/devicetree/bindings/clock/clock-bindings.txt
+
+Examples:
+
+	enet0: ethoc@fd030000 {
+		compatible = "opencores,ethoc";
+		reg = <0xfd030000 0x4000 0xfd800000 0x4000>;
+		interrupts = <1>;
+		local-mac-address = [00 50 c2 13 6f 00];
+		clocks = <&osc>;
+        };
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
