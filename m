From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH v3 1/5] dt-bindings: net: Broadcom iProc MDIO bus driver device tree binding
Date: Tue, 6 Oct 2015 12:25:46 -0700
Message-ID: <1444159550-3432-2-git-send-email-arunp@broadcom.com>
References: <1444159550-3432-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444159550-3432-1-git-send-email-arunp@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree binding documentation for the Broadcom iProc MDIO
bus driver.

Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
---
 .../devicetree/bindings/net/brcm,iproc-mdio.txt    | 23 ++++++++++++++++++++++
 1 file changed, 23 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt b/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
new file mode 100644
index 0000000..8ba9ed1
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
@@ -0,0 +1,23 @@
+* Broadcom iProc MDIO bus controller
+
+Required properties:
+- compatible: should be "brcm,iproc-mdio"
+- reg: address and length of the register set for the MDIO interface
+- #size-cells: must be 1
+- #address-cells: must be 0
+
+Child nodes of this MDIO bus controller node are standard Ethernet PHY device
+nodes as described in Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+
+mdio@18002000 {
+	compatible = "brcm,iproc-mdio";
+	reg = <0x18002000 0x8>;
+	#size-cells = <1>;
+	#address-cells = <0>;
+
+	enet-gphy@0 {
+		reg = <0>;
+	};
+};
-- 
2.5.2
