From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v4 12/13] arm64: dts: marvell: 7040-db: add comphy references to Ethernet ports
Date: Wed, 30 Aug 2017 10:29:23 +0200
Message-ID: <20170830082924.3180-13-antoine.tenart@free-electrons.com>
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

This patch adds comphy phandles to the Ethernet ports in the 7040-db
device tree. The comphy is used to configure the serdes PHYs used by
these ports.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm64/boot/dts/marvell/armada-7040-db.dts | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-7040-db.dts b/arch/arm64/boot/dts/marvell/armada-7040-db.dts
index 92c761c380d3..03d1c42d7c47 100644
--- a/arch/arm64/boot/dts/marvell/armada-7040-db.dts
+++ b/arch/arm64/boot/dts/marvell/armada-7040-db.dts
@@ -180,6 +180,7 @@
 	status = "okay";
 	phy = <&phy0>;
 	phy-mode = "sgmii";
+	phys = <&cpm_comphy0 1>;
 };
 
 &cpm_eth2 {
-- 
2.13.5
