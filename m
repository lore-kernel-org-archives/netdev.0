From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v2 3/4] Documentation: DT: net: Update binding doc for gmiitorgmii conveter
Date: Mon, 4 Jul 2016 14:34:43 +0530
Message-ID: <1467623084-15471-4-git-send-email-appanad@xilinx.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the macb device-tree binding doc for adding
Support for gmiitorgmii converter support.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v2:
--> New patch.

 Documentation/devicetree/bindings/net/macb.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5a42df..0d497a7 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -23,6 +23,10 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- gmii2rgmii-phy-handle: phy-handle for gmiitorgmii converter.
+			 See xilinx_gmii2rgmii.txt file in the same directory.
+
 Optional properties for PHY child node:
 - reset-gpios : Should specify the gpio for phy reset
 - magic-packet : If present, indicates that the hardware supports waking
-- 
2.1.2
