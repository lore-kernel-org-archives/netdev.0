From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/3] ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
Date: Mon, 22 Apr 2013 23:50:37 +0530
Message-ID: <1366654838-26479-3-git-send-email-mugunthanvnm@ti.com>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:50209 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab3DVSUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 14:20:54 -0400
In-Reply-To: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add phy_id device tree data to am335x-evmsk device to bring up CPSW
ethernet present on am335x starter kit.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-evmsk.dts |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index f5a6162..f297b85 100644
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
