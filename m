From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v2 6/7] Binding:PHY: Binding doc for NS2 PCIe PHYs.
Date: Tue, 31 May 2016 19:06:40 +0530
Message-ID: <1464701801-17243-7-git-send-email-pramod.kumar@broadcom.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35287 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbcEaNgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 09:36:46 -0400
Received: by mail-pa0-f41.google.com with SMTP id fy7so55032670pac.2
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 06:36:45 -0700 (PDT)
In-Reply-To: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding doc for NS2 PCIe PHYs.

Signed-off-by: Jon Mason <jonmason@broadcom.com>
Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
---
 .../bindings/phy/brcm,mdio-mux-bus-pci.txt         | 27 ++++++++++++++++++++++
 1 file changed, 27 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt

diff --git a/Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt b/Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt
new file mode 100644
index 0000000..5b51007
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/brcm,mdio-mux-bus-pci.txt
@@ -0,0 +1,27 @@
+* Broadcom NS2 PCIe PHY binding document
+
+Required bus properties:
+- reg: MDIO Bus number for the MDIO interface
+- #address-cells: must be 1
+- #size-cells: must be 0
+
+Required PHY properties:
+- compatible: should be "brcm,ns2-pcie-phy"
+- reg: MDIO Phy ID for the MDIO interface
+- #phy-cells: must be 0
+
+This is a child bus node of "brcm,mdio-mux-iproc" node.
+
+Example:
+
+mdio@0 {
+	reg = <0x0>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	pci_phy0: pci-phy@0 {
+		compatible = "brcm,ns2-pcie-phy";
+		reg = <0x0>;
+		#phy-cells = <0>;
+	};
+};
-- 
1.9.1
