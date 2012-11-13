From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v6 6/7] arm: mvebu: enable Ethernet controllers on OpenBlocks AX3-4 platform
Date: Tue, 13 Nov 2012 16:00:42 +0100
Message-ID: <1352818843-4457-7-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:49805 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab2KMPCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 10:02:41 -0500
In-Reply-To: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PlatHome OpenBlocks AX3-4 platform has 4 Ethernet ports, connected
to a single quad-port PHY through SGMII.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts |   43 ++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
index cb86853..bb8d83c 100644
--- a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
+++ b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
@@ -65,5 +65,48 @@
 				linux,default-trigger = "heartbeat";
 			};
 		};
+
+		mdio {
+			phy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			phy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+
+			phy2: ethernet-phy@2 {
+				reg = <2>;
+			};
+
+			phy3: ethernet-phy@3 {
+				reg = <3>;
+			};
+		};
+
+		ethernet@d0070000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy0>;
+			phy-mode = "sgmii";
+		};
+		ethernet@d0074000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy1>;
+			phy-mode = "sgmii";
+		};
+		ethernet@d0030000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy2>;
+			phy-mode = "sgmii";
+		};
+		ethernet@d0034000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy3>;
+			phy-mode = "sgmii";
+		};
 	};
 };
-- 
1.7.9.5
