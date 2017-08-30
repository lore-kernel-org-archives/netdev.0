From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v4 09/13] arm64: dts: marvell: extend the cp110 syscon register area length
Date: Wed, 30 Aug 2017 10:29:20 +0200
Message-ID: <20170830082924.3180-10-antoine.tenart@free-electrons.com>
References: <20170830082924.3180-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830082924.3180-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch extends on both cp110 the system register area length to
include some of the comphy registers as well.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi | 2 +-
 arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index 18299e164cb7..9b2581473183 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
@@ -118,7 +118,7 @@
 
 			cpm_syscon0: system-controller@440000 {
 				compatible = "syscon", "simple-mfd";
-				reg = <0x440000 0x1000>;
+				reg = <0x440000 0x2000>;
 
 				cpm_clk: clock {
 					compatible = "marvell,cp110-clock";
diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
index 5ae8fa575859..d3902f218c46 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
@@ -125,7 +125,7 @@
 
 			cps_syscon0: system-controller@440000 {
 				compatible = "syscon", "simple-mfd";
-				reg = <0x440000 0x1000>;
+				reg = <0x440000 0x2000>;
 
 				cps_clk: clock {
 					compatible = "marvell,cp110-clock";
-- 
2.13.5
