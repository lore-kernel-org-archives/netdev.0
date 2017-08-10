From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v4 2/4] dt-bindings: can: can-transceiver: Document new binding
Date: Wed, 9 Aug 2017 19:59:14 -0500
Message-ID: <20170810005916.27163-3-fcooper@ti.com>
References: <20170810005916.27163-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>, <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170810005916.27163-1-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add documentation to describe usage of the new can-transceiver binding.
This new binding is applicable for any CAN device therefore it exists as
its own document.

Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
---
Version 4 changes:
Drop unit address.
Switch from using fixed-transceiver to can-transceiver

 .../bindings/net/can/can-transceiver.txt           | 24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/can-transceiver.txt

diff --git a/Documentation/devicetree/bindings/net/can/can-transceiver.txt b/Documentation/devicetree/bindings/net/can/can-transceiver.txt
new file mode 100644
index 0000000..2c31dc0
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/can-transceiver.txt
@@ -0,0 +1,24 @@
+Generic CAN transceiver Device Tree binding
+------------------------------
+
+CAN transceiver typically limits the max speed in standard CAN and CAN FD
+modes. Typically these limitations are static and the transceivers themselves
+provide no way to detect this limitation at runtime. For this situation,
+the "can-transceiver" node can be used.
+
+Required Properties:
+ max-bitrate:	a positive non 0 value that determines the max
+		speed that CAN/CAN-FD can run. Any other value
+		will be ignored.
+
+Examples:
+
+Based on Texas Instrument's TCAN1042HGV CAN Transceiver
+
+m_can0 {
+	....
+	can-transceiver@ {
+		max-bitrate = <5000000>;
+	};
+	...
+};
-- 
2.9.4.dirty

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
