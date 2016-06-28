From: Jon Mason <jon.mason@broadcom.com>
Subject: [RFC 6/7] dt-bindings: net: bgmac: add bindings documentation for bgmac
Date: Tue, 28 Jun 2016 15:34:43 -0400
Message-ID: <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 .../devicetree/bindings/net/brcm,bgmac-enet.txt     | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
new file mode 100644
index 0000000..efd36d5
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
@@ -0,0 +1,21 @@
+Broadcom GMAC Ethernet Controller Device Tree Bindings
+-------------------------------------------------------------
+
+Required properties:
+ - compatible:	"brcm,bgmac-enet"
+ - reg:		Address and length of the GMAC registers,
+		Address and length of the GMAC IDM registers
+ - interrupts:	Interrupt number
+
+Optional properties:
+- mac-address:	mac address to be assigned to the device
+
+Examples:
+
+gmac0: enet@18022000 {
+	compatible = "brcm,bgmac-enet";
+	reg = <0x18022000 0x1000>,
+	      <0x18110000 0x1000>;
+	interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
+	status = "disabled";
+};
-- 
1.9.1
