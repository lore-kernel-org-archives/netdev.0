From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 2/4] can: fixed-transceiver: Add documentation for CAN fixed transceiver bindings
Date: Wed, 19 Jul 2017 18:36:52 -0500
Message-ID: <20170719233654.25908-3-fcooper@ti.com>
References: <20170719233654.25908-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719233654.25908-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add documentation to describe usage of the new fixed transceiver binding.
This new binding is applicable for any CAN device therefore it exist as
its own document.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 .../bindings/net/can/fixed-transceiver.txt         | 31 ++++++++++++++++++++++
 1 file changed, 31 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

diff --git a/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
new file mode 100644
index 0000000..7c093c3
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
@@ -0,0 +1,31 @@
+Fixed transceiver Device Tree binding
+------------------------------
+
+CAN transceiver typically limits the max speed in standard CAN and CAN FD
+modes. Typically these limitations are static and the transceivers themselves
+provide no way to detect this limitation at runtime. For this situation,
+the "fixed-transceiver" node can be used.
+
+Properties:
+
+Optional:
+ max-arbitration-speed: a positive value non 0 value that determines the max
+			 speed CAN can run in non CAN-FD mode or during the
+			 arbitration phase in CAN-FD mode.
+
+ max-data-speed:	 a positive value that determines the max data rate
+			 that can be used in CAN-FD mode. A value of 0
+			 implies CAN-FD is not supported by the transceiver.
+
+Examples:
+
+Based on Texas Instrument's TCAN1042HGV CAN Transceiver
+
+m_can0 {
+	....
+	fixed-transceiver@0 {
+		max-arbitration-speed = <1000000>;
+		max-data-speed = <5000000>;
+	};
+	...
+};
-- 
2.10.0
