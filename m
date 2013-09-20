From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 4/4] ARM: dts: am33xx: adopt to cpsw-phy-sel driver to configure phy mode
Date: Sat, 21 Sep 2013 00:50:41 +0530
Message-ID: <1379704841-32693-5-git-send-email-mugunthanvnm@ti.com>
References: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zonque@gmail.com>, <davem@davemloft.net>, <bcousson@baylibre.com>,
	<tony@atomide.com>, <devicetree@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48766 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab3ITTVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 15:21:55 -0400
In-Reply-To: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DT entries for the phy mode selection in AM33xx SoC using cpsw-phy-sel
driver.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Tested-by: Daniel Mack <zonque@gmail.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index f9c5da9..d76ae24 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -594,6 +594,12 @@
 				/* Filled in by U-Boot */
 				mac-address = [ 00 00 00 00 00 00 ];
 			};
+
+			phy_sel: cpsw-phy-sel@44e10650 {
+				compatible = "ti,am3352-cpsw-phy-sel";
+				reg= <0x44e10650 0x4>;
+				reg-names = "gmii-sel";
+			};
 		};
 
 		ocmcram: ocmcram@40300000 {
-- 
1.8.4
