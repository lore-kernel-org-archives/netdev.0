From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 4/4] arm: mvebu: enable Ethernet controllers on Armada 370/XP eval boards
Date: Thu, 11 Oct 2012 17:28:02 +0200
Message-ID: <1349969282-12676-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35262 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932910Ab2JKP2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:28:49 -0400
In-Reply-To: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the two network interfaces of the Armada 370
official Marvell evaluation platform, and the four network interfaces
of the Armada XP official Marvell evaluation platform.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-db.dts |   12 ++++++++++++
 arch/arm/boot/dts/armada-xp-db.dts  |   24 ++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-db.dts b/arch/arm/boot/dts/armada-370-db.dts
index fffd5c2..bb18b0d 100644
--- a/arch/arm/boot/dts/armada-370-db.dts
+++ b/arch/arm/boot/dts/armada-370-db.dts
@@ -38,5 +38,17 @@
 			clock-frequency = <600000000>;
 			status = "okay";
 		};
+                eth@d0070000 {
+                        clock-frequency = <200000000>;
+                        status = "okay";
+                        phy-mode = "rgmii";
+                        phy-addr = <0>;
+                };
+                eth@d0074000 {
+                        clock-frequency = <200000000>;
+                        status = "okay";
+                        phy-mode = "rgmii";
+                        phy-addr = <1>;
+                };
 	};
 };
diff --git a/arch/arm/boot/dts/armada-xp-db.dts b/arch/arm/boot/dts/armada-xp-db.dts
index f97040d..d1a4173 100644
--- a/arch/arm/boot/dts/armada-xp-db.dts
+++ b/arch/arm/boot/dts/armada-xp-db.dts
@@ -46,5 +46,29 @@
 			clock-frequency = <250000000>;
 			status = "okay";
 		};
+                eth@d0070000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "rgmii";
+                        phy-addr = <0>;
+                };
+                eth@d0074000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "rgmii";
+                        phy-addr = <1>;
+                };
+                eth@d0030000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "sgmii";
+                        phy-addr = <25>;
+                };
+                eth@d0034000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "sgmii";
+                        phy-addr = <27>;
+                };
 	};
 };
-- 
1.7.9.5
