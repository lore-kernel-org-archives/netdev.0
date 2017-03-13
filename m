From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v3 1/2] can: holt_hi311x: document device tree bindings
Date: Mon, 13 Mar 2017 11:34:39 -0400
Message-ID: <1489419280-19187-1-git-send-email-akshay.bhat@timesys.com>
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Document the HOLT HI-311x CAN device tree bindings.

Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---

v2 -> v3:
- No changes

 .../devicetree/bindings/net/can/holt_hi311x.txt    | 24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/holt_hi311x.txt

diff --git a/Documentation/devicetree/bindings/net/can/holt_hi311x.txt b/Documentation/devicetree/bindings/net/can/holt_hi311x.txt
new file mode 100644
index 0000000..23aa94e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/holt_hi311x.txt
@@ -0,0 +1,24 @@
+* Holt HI-311X stand-alone CAN controller device tree bindings
+
+Required properties:
+ - compatible: Should be one of the following:
+   - "holt,hi3110" for HI-3110
+ - reg: SPI chip select.
+ - clocks: The clock feeding the CAN controller.
+ - interrupt-parent: The parent interrupt controller.
+ - interrupts: Should contain IRQ line for the CAN controller.
+
+Optional properties:
+ - vdd-supply: Regulator that powers the CAN controller.
+ - xceiver-supply: Regulator that powers the CAN transceiver.
+
+Example:
+	can0: can@1 {
+		compatible = "holt,hi3110";
+		reg = <1>;
+		clocks = <&clk32m>;
+		interrupt-parent = <&gpio4>;
+		interrupts = <13 IRQ_TYPE_EDGE_RISING>;
+		vdd-supply = <&reg5v0>;
+		xceiver-supply = <&reg5v0>;
+	};
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
