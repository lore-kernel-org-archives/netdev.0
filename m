From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 8/8] arm64: dts: marvell: add TX interrupts for PPv2.2
Date: Tue, 25 Jul 2017 17:55:09 +0200
Message-ID: <20170725155509.10574-9-thomas.petazzoni@free-electrons.com>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Cc: Russell King <linux@arm.linux.org.uk>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60466 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbdGYPzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:55:41 -0400
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit updates the Marvell Armada 7K/8K Device Tree to describe
the TX interrupts of the Ethernet controllers, in both the master and
slave CP110s.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
Dave: please do *not* apply this patch. It will go through the ARM
mvebu maintainers. Thanks!

 .../arm64/boot/dts/marvell/armada-cp110-master.dtsi | 21 ++++++++++++++++++---
 arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi | 21 ++++++++++++++++++---
 2 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index 9278ba6..d192cea 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
@@ -71,8 +71,13 @@
 
 				cpm_eth0: eth0 {
 					interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 43 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 47 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 51 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 55 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 129 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <0>;
 					gop-port-id = <0>;
 					status = "disabled";
@@ -80,8 +85,13 @@
 
 				cpm_eth1: eth1 {
 					interrupts = <ICU_GRP_NSR 40 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 44 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 48 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 52 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 56 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 128 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <1>;
 					gop-port-id = <2>;
 					status = "disabled";
@@ -89,8 +99,13 @@
 
 				cpm_eth2: eth2 {
 					interrupts = <ICU_GRP_NSR 41 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 45 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 49 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 53 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 57 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 127 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <2>;
 					gop-port-id = <3>;
 					status = "disabled";
diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
index 3515817..8bde91b 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
@@ -78,8 +78,13 @@
 
 				cps_eth0: eth0 {
 					interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 43 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 47 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 51 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 55 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 129 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <0>;
 					gop-port-id = <0>;
 					status = "disabled";
@@ -87,8 +92,13 @@
 
 				cps_eth1: eth1 {
 					interrupts = <ICU_GRP_NSR 40 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 44 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 48 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 52 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 56 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 128 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <1>;
 					gop-port-id = <2>;
 					status = "disabled";
@@ -96,8 +106,13 @@
 
 				cps_eth2: eth2 {
 					interrupts = <ICU_GRP_NSR 41 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 45 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 49 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 53 IRQ_TYPE_LEVEL_HIGH>,
+						     <ICU_GRP_NSR 57 IRQ_TYPE_LEVEL_HIGH>,
 						     <ICU_GRP_NSR 127 IRQ_TYPE_LEVEL_HIGH>;
-					interrupt-names = "rx-shared", "link";
+					interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+							  "tx-cpu3", "rx-shared", "link";
 					port-id = <2>;
 					gop-port-id = <3>;
 					status = "disabled";
-- 
2.9.4
