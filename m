From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 5/5] ARM: mvebu: use the fixed-link PHY DT binding for the Armada XP Matrix board
Date: Fri, 16 May 2014 16:14:07 +0200
Message-ID: <1400249647-4643-6-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:41089 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757294AbaEPOOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:14:17 -0400
In-Reply-To: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Armada XP Matrix board has an Ethernet PHY that isn't configurable
through the MDIO bus, so we use the newly introduced fixed-link PHY DT
binding to represent the PHY of this platform and get network working.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp-matrix.dts | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/boot/dts/armada-xp-matrix.dts b/arch/arm/boot/dts/armada-xp-matrix.dts
index c224274..3bb8c00 100644
--- a/arch/arm/boot/dts/armada-xp-matrix.dts
+++ b/arch/arm/boot/dts/armada-xp-matrix.dts
@@ -61,6 +61,10 @@
 			ethernet@30000 {
 				status = "okay";
 				phy-mode = "sgmii";
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+				};
 			};
 
 			pcie-controller {
-- 
1.9.3
