From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v3 2/4] dt-bindings: can: fixed-transceiver: Add new CAN fixed transceiver bindings
Date: Wed, 2 Aug 2017 19:51:48 -0500
Message-ID: <20170803005150.9286-3-fcooper@ti.com>
References: <20170803005150.9286-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803005150.9286-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add documentation to describe usage of the new fixed transceiver binding.
This new binding is applicable for any CAN device therefore it exists as
its own document.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 .../bindings/net/can/fixed-transceiver.txt         | 24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

diff --git a/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
new file mode 100644
index 0000000..2f58838b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
@@ -0,0 +1,24 @@
+Fixed transceiver Device Tree binding
+------------------------------
+
+CAN transceiver typically limits the max speed in standard CAN and CAN FD
+modes. Typically these limitations are static and the transceivers themselves
+provide no way to detect this limitation at runtime. For this situation,
+the "fixed-transceiver" node can be used.
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
+	fixed-transceiver@0 {
+		max-bitrate = <5000000>;
+	};
+	...
+};
-- 
2.9.4.dirty
