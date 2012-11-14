From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v7 6/6] arm: mvebu: enable Ethernet controllers on OpenBlocks AX3-4 platform
Date: Wed, 14 Nov 2012 15:56:50 +0100
Message-ID: <1352905010-24172-7-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([88.190.12.23]:33183 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738Ab2KNO5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:57:22 -0500
In-Reply-To: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PlatHome OpenBlocks AX3-4 platform has 4 Ethernet ports, connected
to a single quad-port PHY through SGMII.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts |   24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
index cb86853..1a07e09 100644
--- a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
+++ b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
@@ -65,5 +65,29 @@
 				linux,default-trigger = "heartbeat";
 			};
 		};
+		ethernet@d0070000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy-mode = "sgmii";
+			phy-addr = <0>;
+		};
+		ethernet@d0074000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy-mode = "sgmii";
+			phy-addr = <1>;
+		};
+		ethernet@d0030000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy-mode = "sgmii";
+			phy-addr = <2>;
+		};
+		ethernet@d0034000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy-mode = "sgmii";
+			phy-addr = <3>;
+		};
 	};
 };
-- 
1.7.9.5
