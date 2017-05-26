From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: [PATCH v3 2/2] dt-bindings: net: Add Cortina device tree bindings
Date: Fri, 26 May 2017 07:58:39 +0000
Message-ID: <1495785519-1468-3-git-send-email-bogdan.purcareata@nxp.com>
References: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree description info for Cortina 10G phy devices.

Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
---
Patch introduced in v3 of the patchset.

 Documentation/devicetree/bindings/net/cortina.txt | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/cortina.txt

diff --git a/Documentation/devicetree/bindings/net/cortina.txt b/Documentation/devicetree/bindings/net/cortina.txt
new file mode 100644
index 0000000..006a1ee
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/cortina.txt
@@ -0,0 +1,19 @@
+Cortina Phy Driver Device Tree Bindings
+---------------------------------------
+
+The driver supports the Cortina Electronic Dispersion Compensation (EDC)
+devices, equipped with clock and data recovery (CDR) circuits. These
+devices make use of registers that are not compatible with Clause 45 or
+Clause 22, therefore they need to be described using the
+"ethernet-phy-id" compatible.
+
+Since the driver only implements  polling mode support, interrupts info
+can be skipped.
+
+Example (CS4340 phy):
+	mdio {
+		cs4340_phy@1 {
+			compatible = "ethernet-phy-id13e5.1002";
+			reg = <0x10>;
+		};
+	};
-- 
1.9.1
