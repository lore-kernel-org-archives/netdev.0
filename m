From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH 2/2] net: stmmac: meson: document device tree bindings
Date: Sat, 20 Sep 2014 15:29:17 +0200
Message-ID: <1411219757-9201-3-git-send-email-b.galvani@gmail.com>
References: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Carlo Caione <carlo@caione.org>,
	Jerry Cao <jerry.cao@amlogic.com>,
	Victor Wan <victor.wan@amlogic.com>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:38170 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904AbaITNbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 09:31:41 -0400
In-Reply-To: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the device tree bindings documentation for the Amlogic Meson
variant of the Synopsys DesignWare MAC.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 .../devicetree/bindings/net/meson-dwmac.txt        | 25 ++++++++++++++++++++++
 1 file changed, 25 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/meson-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/meson-dwmac.txt b/Documentation/devicetree/bindings/net/meson-dwmac.txt
new file mode 100644
index 0000000..ec633d7
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/meson-dwmac.txt
@@ -0,0 +1,25 @@
+* Amlogic Meson DWMAC Ethernet controller
+
+The device inherits all the properties of the dwmac/stmmac devices
+described in the file net/stmmac.txt with the following changes.
+
+Required properties:
+
+- compatible: should be "amlogic,meson6-dwmac" along with "snps,dwmac"
+	      and any applicable more detailed version number
+	      described in net/stmmac.txt
+
+- reg: should contain a register range for the dwmac controller and
+       another one for the Amlogic specific configuration
+
+Example:
+
+	ethmac: ethernet@c9410000 {
+		compatible = "amlogic,meson6-dwmac", "snps,dwmac";
+		reg = <0xc9410000 0x10000
+		       0xc1108108 0x4>;
+		interrupts = <0 8 1>;
+		interrupt-names = "macirq";
+		clocks = <&clk81>;
+		clock-names = "stmmaceth";
+	}
-- 
1.9.1
