From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next resend PATCH 4/6] ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
Date: Tue, 21 May 2013 15:25:01 +0530
Message-ID: <1369130103-743-5-git-send-email-mugunthanvnm@ti.com>
References: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.orgm>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add phy_id device tree data to am335x-evmsk device to bring up CPSW
ethernet present on am335x starter kit.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-evmsk.dts |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index f67c360..acbcac3 100644
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@ -248,3 +248,11 @@
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
1.7.9.5

