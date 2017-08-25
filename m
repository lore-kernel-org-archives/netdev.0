From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 12/14] arm64: dts: marvell: mcbin: add comphy references to Ethernet ports
Date: Fri, 25 Aug 2017 16:48:19 +0200
Message-ID: <20170825144821.31129-13-antoine.tenart@free-electrons.com>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds comphy phandles to the Ethernet ports in the mcbin
device tree. The comphy is used to configure the serdes PHYs used by
these ports.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts b/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
index 9f0a00802452..970081ca197b 100644
--- a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
+++ b/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
@@ -148,6 +148,7 @@
 &cpm_eth0 {
 	status = "okay";
 	phy = <&phy0>;
+	phys = <&cpm_comphy4 0>;
 	phy-mode = "10gbase-kr";
 };
 
@@ -181,6 +182,7 @@
 &cps_eth0 {
 	status = "okay";
 	phy = <&phy8>;
+	phys = <&cps_comphy4 0>;
 	phy-mode = "10gbase-kr";
 };
 
@@ -189,6 +191,7 @@
 	status = "okay";
 	phy = <&ge_phy>;
 	phy-mode = "sgmii";
+	phys = <&cps_comphy0 1>;
 };
 
 &cps_sata0 {
-- 
2.13.5
