From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 18/18] arm64: dts: marvell: 8040-db: enable the SFP ports
Date: Mon, 24 Jul 2017 15:48:48 +0200
Message-ID: <20170724134848.19330-19-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47429 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755891AbdGXNuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:09 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the SFP ports on the Armada 8040 DB as these ports
are now supported by the PPv2 driver (since the PHY is now optional).

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---

@Dave: Hi! This patch should go through the mvebu tree. Thanks!

 arch/arm64/boot/dts/marvell/armada-8040-db.dts | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-8040-db.dts b/arch/arm64/boot/dts/marvell/armada-8040-db.dts
index 1e8f7242ed6f..83c7d8f2f710 100644
--- a/arch/arm64/boot/dts/marvell/armada-8040-db.dts
+++ b/arch/arm64/boot/dts/marvell/armada-8040-db.dts
@@ -136,6 +136,11 @@
 	status = "okay";
 };
 
+&cpm_eth0 {
+	status = "okay";
+	phy-mode = "10gbase-kr";
+};
+
 &cpm_eth2 {
 	status = "okay";
 	phy = <&phy1>;
@@ -179,6 +184,11 @@
 	status = "okay";
 };
 
+&cps_eth0 {
+	status = "okay";
+	phy-mode = "10gbase-kr";
+};
+
 &cps_eth1 {
 	status = "okay";
 	phy = <&phy0>;
-- 
2.13.3
