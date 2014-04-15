From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/3] ARM: mvebu: use qsgmii phy-mode for Armada XP GP interfaces
Date: Tue, 15 Apr 2014 15:50:21 +0200
Message-ID: <1397569821-5530-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	George Joseph <george.joseph@fairview5.com>, arno@natisbad.org,
	Willy Tarreau <w@1wt.eu>,
	Alexander Reuter <Alexander.Reuter@gmx.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40767 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753946AbaDONu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 09:50:28 -0400
In-Reply-To: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Armada XP GP isn't using rgmii-id connections between the MAC and
PHY, but instead a single QSGMII connection, which is a quad-SGMII
connection: a double pair of differential lines that are multiplexed
to convey the traffic of four network interfaces between a MAC and a
PHY.

Until now, the Armada XP GP was relying on the bootloader setting the
correct values in various configuration registers. With this change,
the mvneta driver can be used as a module on this platform.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp-gp.dts | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/armada-xp-gp.dts b/arch/arm/boot/dts/armada-xp-gp.dts
index 61bda68..c921f3b 100644
--- a/arch/arm/boot/dts/armada-xp-gp.dts
+++ b/arch/arm/boot/dts/armada-xp-gp.dts
@@ -146,22 +146,22 @@
 			ethernet@70000 {
 				status = "okay";
 				phy = <&phy0>;
-				phy-mode = "rgmii-id";
+				phy-mode = "qsgmii";
 			};
 			ethernet@74000 {
 				status = "okay";
 				phy = <&phy1>;
-				phy-mode = "rgmii-id";
+				phy-mode = "qsgmii";
 			};
 			ethernet@30000 {
 				status = "okay";
 				phy = <&phy2>;
-				phy-mode = "rgmii-id";
+				phy-mode = "qsgmii";
 			};
 			ethernet@34000 {
 				status = "okay";
 				phy = <&phy3>;
-				phy-mode = "rgmii-id";
+				phy-mode = "qsgmii";
 			};
 
 			/* Front-side USB slot */
-- 
1.8.3.2
