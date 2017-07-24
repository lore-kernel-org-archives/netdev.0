From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 13/18] arm64: dts: marvell: cp110: use named interrupts for the Ethernet ports
Date: Mon, 24 Jul 2017 15:48:43 +0200
Message-ID: <20170724134848.19330-14-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47398 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753918AbdGXNuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:07 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPv2 driver now uses named interrupts. Add the interrupt-names
property to the Ethernet ports to use this new functionality. This is
needed as other interrupt descriptions will be added to the Ethernet
ports at some point.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---

@Dave: Hi! This patch should go through the mvebu tree. Thanks!

 arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi | 3 +++
 arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi  | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
index 4c68605675a8..13763eefeb6e 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-master.dtsi
@@ -70,6 +70,7 @@
 
 				cpm_eth0: eth0 {
 					interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <0>;
 					gop-port-id = <0>;
 					status = "disabled";
@@ -77,6 +78,7 @@
 
 				cpm_eth1: eth1 {
 					interrupts = <ICU_GRP_NSR 40 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <1>;
 					gop-port-id = <2>;
 					status = "disabled";
@@ -84,6 +86,7 @@
 
 				cpm_eth2: eth2 {
 					interrupts = <ICU_GRP_NSR 41 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <2>;
 					gop-port-id = <3>;
 					status = "disabled";
diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
index 0dbb59811d00..0382cffef189 100644
--- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
@@ -77,6 +77,7 @@
 
 				cps_eth0: eth0 {
 					interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <0>;
 					gop-port-id = <0>;
 					status = "disabled";
@@ -84,6 +85,7 @@
 
 				cps_eth1: eth1 {
 					interrupts = <ICU_GRP_NSR 40 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <1>;
 					gop-port-id = <2>;
 					status = "disabled";
@@ -91,6 +93,7 @@
 
 				cps_eth2: eth2 {
 					interrupts = <ICU_GRP_NSR 41 IRQ_TYPE_LEVEL_HIGH>;
+					interrupt-names = "rx-shared";
 					port-id = <2>;
 					gop-port-id = <3>;
 					status = "disabled";
-- 
2.13.3
