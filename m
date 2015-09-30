From: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 1/4] dt-bindings: net: Broadcom iProc MDIO bus driver device tree binding
Date: Wed, 30 Sep 2015 13:32:40 -0700
Message-ID: <1443645163-2822-2-git-send-email-arunp@broadcom.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443645163-2822-1-git-send-email-arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add device tree binding documentation for the Broadcom iProc MDIO
bus driver.

Signed-off-by: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 .../devicetree/bindings/net/brcm,iproc-mdio.txt    | 23 ++++++++++++++++++++++
 1 file changed, 23 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt b/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
new file mode 100644
index 0000000..689f97c
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
+mdio@0x18002000 {
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
