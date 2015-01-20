From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v2 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb board enet phy address
Date: Tue, 20 Jan 2015 16:48:17 +0800
Message-ID: <1421743697-26918-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <s.hauer@pengutronix.de>,
	<stefan@agner.ch>, <linux-arm-kernel@lists.infradead.org>,
	<b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0118.outbound.protection.outlook.com ([157.56.111.118]:24000
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751241AbbATIv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 03:51:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
the commit add mdio node with un-correct phy address.

The patch just correct i.MX6sx sdb board enet phy address.

V2:
* As Shawn's suggestion that unit-address should match 'reg' property, so
  update ethernet-phy unit-address.

Acked-by: Stefan Agner <stefan@agner.ch>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx6sx-sdb.dts |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts b/arch/arm/boot/dts/imx6sx-sdb.dts
index 8c1febd..c108bb4 100644
--- a/arch/arm/boot/dts/imx6sx-sdb.dts
+++ b/arch/arm/boot/dts/imx6sx-sdb.dts
@@ -166,12 +166,12 @@
 		#address-cells = <1>;
 		#size-cells = <0>;
 
-		ethphy1: ethernet-phy@0 {
-			reg = <0>;
+		ethphy1: ethernet-phy@1 {
+			reg = <1>;
 		};
 
-		ethphy2: ethernet-phy@1 {
-			reg = <1>;
+		ethphy2: ethernet-phy@2 {
+			reg = <2>;
 		};
 	};
 };
-- 
1.7.8
