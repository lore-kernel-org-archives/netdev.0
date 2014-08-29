From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 5/5] ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP
Date: Fri, 29 Aug 2014 15:51:03 +0200
Message-ID: <1409320263-10295-6-git-send-email-antoine.tenart@free-electrons.com>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables the Ethernet port on the Marvell Berlin2Q DMP board.
The Ethernet PHY node is also added.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm/boot/dts/berlin2q-marvell-dmp.dts | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/arm/boot/dts/berlin2q-marvell-dmp.dts b/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
index a357ce02a64e..1826534ffce3 100644
--- a/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
+++ b/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
@@ -45,3 +45,16 @@
 &uart0 {
 	status = "okay";
 };
+
+&eth0 {
+	phy-handle = <&ethphy0>;
+	status = "okay";
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
-- 
1.9.1
