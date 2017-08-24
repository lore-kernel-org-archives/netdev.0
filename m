From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 11/13] arm64: dts: marvell: add comphy nodes on cp110 master and slave
Date: Thu, 24 Aug 2017 10:38:21 +0200
Message-ID: <20170824083823.16826-12-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the comphy driver is available, this patch adds the
corresponding nodes in the cp110 master and slave device trees.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 .../boot/dts/marvell/armada-cp110-master.dtsi      | 38 ++++++++++++++++++++++
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi | 38 ++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index 9b2581473183..f2a50552bad4 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
@@ -91,6 +91,44 @@
 				};
 			};
 
+			cpm_comphy: phy@120000 {
+				compatible = "marvell,comphy-cp110";
+				reg = <0x120000 0x6000>;
+				marvell,system-controller = <&cpm_syscon0>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				cpm_comphy0: phy@0 {
+					reg = <0>;
+					#phy-cells = <1>;
+				};
+
+				cpm_comphy1: phy@1 {
+					reg = <1>;
+					#phy-cells = <1>;
+				};
+
+				cpm_comphy2: phy@2 {
+					reg = <2>;
+					#phy-cells = <1>;
+				};
+
+				cpm_comphy3: phy@3 {
+					reg = <3>;
+					#phy-cells = <1>;
+				};
+
+				cpm_comphy4: phy@4 {
+					reg = <4>;
+					#phy-cells = <1>;
+				};
+
+				cpm_comphy5: phy@5 {
+					reg = <5>;
+					#phy-cells = <1>;
+				};
+			};
+
 			cpm_mdio: mdio@12a200 {
 				#address-cells = <1>;
 				#size-cells = <0>;
diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
index d3902f218c46..bd7f7d0e6de9 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
@@ -98,6 +98,44 @@
 				};
 			};
 
+			cps_comphy: phy@120000 {
+				compatible = "marvell,comphy-cp110";
+				reg = <0x120000 0x6000>;
+				marvell,system-controller = <&cps_syscon0>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				cps_comphy0: phy@0 {
+					reg = <0>;
+					#phy-cells = <1>;
+				};
+
+				cps_comphy1: phy@1 {
+					reg = <1>;
+					#phy-cells = <1>;
+				};
+
+				cps_comphy2: phy@2 {
+					reg = <2>;
+					#phy-cells = <1>;
+				};
+
+				cps_comphy3: phy@3 {
+					reg = <3>;
+					#phy-cells = <1>;
+				};
+
+				cps_comphy4: phy@4 {
+					reg = <4>;
+					#phy-cells = <1>;
+				};
+
+				cps_comphy5: phy@5 {
+					reg = <5>;
+					#phy-cells = <1>;
+				};
+			};
+
 			cps_mdio: mdio@12a200 {
 				#address-cells = <1>;
 				#size-cells = <0>;
-- 
2.13.5
