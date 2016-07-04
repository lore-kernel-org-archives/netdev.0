From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx gmiitorgmii converter device tree binding documentation
Date: Mon, 4 Jul 2016 14:34:41 +0530
Message-ID: <1467623084-15471-2-git-send-email-appanad@xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<punnaia@xilinx.com>, <nicolas.ferre@atmel.com>,
	<f.fainelli@gmail.com>, <andrew@lunn.ch>, <anirudh@xilinx.com>,
	<harinik@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0050.outbound.protection.outlook.com ([104.47.36.50]:29536
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750895AbcGDJEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 05:04:53 -0400
In-Reply-To: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device-tree binding documentation for xilinx gmiitorgmii converter.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v2:
--> New patch.

 .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 31 ++++++++++++++++++++++
 1 file changed, 31 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt

diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
new file mode 100644
index 0000000..d11e259
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
@@ -0,0 +1,31 @@
+* XILINX GMIITORGMII Converter Driver
+
+The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
+Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
+Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
+This core can be used in all three modes of operation(10/100/1000 Mb/s).
+The Management Data Input/Output (MDIO) interface is used to configure the
+Speed of operation. This core can switch dynamically between the three
+Different speed modes by configuring the conveter register through mdio write.
+
+The MDIO is a bus to which the PHY devices are connected.  For each
+device that exists on this bus, a child node should be created.  See
+the definition of the PHY node in booting-without-of.txt for an example
+of how to define a PHY.
+
+Required properties:
+  - compatible : Should be "xlnx,gmiitorgmii"
+  - reg : The ID number for the phy, usually a small integer
+
+Example:
+	mdio {
+                #address-cells = <1>;
+                #size-cells = <0>;
+		ethernet-phy@0 {
+			......
+		};
+                gmii_to_rgmii: gmii_to_rgmii@8 {
+                        compatible = "xlnx,gmiitorgmii";
+                        reg = <8>;
+                };
+        };
-- 
2.1.2
