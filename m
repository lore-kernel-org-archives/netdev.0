From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH] ARM: dts: rk3228-evb: Fix the compiling error
Date: Tue, 22 Aug 2017 17:24:25 +0800
Message-ID: <1503393865-7975-1-git-send-email-david.wu@rock-chips.com>
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
        David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.135]:55775 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932205AbdHVJTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 05:19:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch solves the following error:
arch/arm/boot/dts/rk3228-evb.dtb: ERROR (phandle_references): Reference to non-existent node or label "phy0"

Fixess db40f15b53e4 ("ARM: dts: rk3228-evb: Enable the integrated PHY for gmac")
Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm/boot/dts/rk3228-evb.dts | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/rk3228-evb.dts b/arch/arm/boot/dts/rk3228-evb.dts
index 456ddf7..1be9daa 100644
--- a/arch/arm/boot/dts/rk3228-evb.dts
+++ b/arch/arm/boot/dts/rk3228-evb.dts
@@ -76,7 +76,7 @@
 	clock_in_out = "output";
 	phy-supply = <&vcc_phy>;
 	phy-mode = "rmii";
-	phy-handle = <&phy0>;
+	phy-handle = <&phy>;
 	status = "okay";
 
 	mdio {
@@ -84,7 +84,7 @@
 		#address-cells = <1>;
 		#size-cells = <0>;
 
-		phy@0 {
+		phy: phy@0 {
 			compatible = "ethernet-phy-id1234.d400", "ethernet-phy-ieee802.3-c22";
 			reg = <0>;
 			clocks = <&cru SCLK_MAC_PHY>;
-- 
1.9.1
