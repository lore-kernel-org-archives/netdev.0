From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 10/11] Documentation: dtb: xgene: Add MDIO node
Date: Wed,  6 Jul 2016 17:35:11 -0700
Message-ID: <1467851712-24780-11-git-send-email-isubramanian@apm.com>
References: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35729 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056AbcGGAfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:35:33 -0400
Received: by mail-pf0-f174.google.com with SMTP id c2so876243pfa.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 17:35:32 -0700 (PDT)
In-Reply-To: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 .../devicetree/bindings/net/apm-xgene-mdio.txt     | 37 ++++++++++++++++++++++
 1 file changed, 37 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-mdio.txt

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt b/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
new file mode 100644
index 0000000..0247e70
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/apm-xgene-mdio.txt
@@ -0,0 +1,37 @@
+APM X-Gene SoC MDIO node
+
+MDIO node is defined to describe on-chip MDIO controller.
+
+Required properties:
+	- compatible: Must be "apm,xgene-mdio-rgmii"
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+	- reg: Address and length of the register set
+	- clocks: Reference to the clock entry
+
+For the phys on the mdio bus, there must be a node with the following fields:
+	- compatible: PHY identifier.  Please refer ./phy.txt for the format.
+	- reg: The ID number for the phy.
+
+Example:
+
+	mdio: mdio@0x17020000 {
+		compatible = "apm,xgene-mdio-rgmii";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0x0 0x17020000 0x0 0xd100>;
+		clocks = <&menetclk 0>;
+	};
+
+	/* Board-specific peripheral configurations */
+	&mdio {
+		menetphy: phy@3 {
+			reg = <0x3>;
+		};
+		sgenet0phy: phy@4 {
+			reg = <0x4>;
+		};
+		sgenet1phy: phy@5 {
+			reg = <0x5>;
+		};
+	};
-- 
1.9.1
