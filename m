From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] ARM: dts: am335x-evmsk: Add cpsw phy_id
Date: Fri, 23 Nov 2012 14:02:14 +0530
Message-ID: <1353659534-6071-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <b-cousson@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add phy id for CPSW

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
The patch is verified with CPSW patches present in the following git repo
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

 arch/arm/boot/dts/am335x-evmsk.dts |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index 6f53879..c629086 100644
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@ -164,3 +164,11 @@
 		};
 	};
 };
+
+&cpsw_emac0 {
+	phy_id = <&davinci_mdio>, <0>;
+};
+
+&cpsw_emac1 {
+	phy_id = <&davinci_mdio>, <1>;
+};
-- 
1.7.0.4

