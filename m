From: varkabhadram@gmail.com
Subject: [PATCH net-next v7 3/3] devicetree: add device tree bindings for cc2520 driver
Date: Fri, 20 Jun 2014 17:47:17 +0530
Message-ID: <53a42763.6ac3440a.5afd.56c7@mx.google.com>
References: <y>
 <1403266637-6150-1-git-send-email-y>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	sowjanyap@cdac.in, venkatas@cdac.in, santoshk@cdac.in,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:50468 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966074AbaFTMV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:21:56 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so2946936pde.3
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 05:21:56 -0700 (PDT)
In-Reply-To: <1403266637-6150-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

DT bindings for cc2520 radio driver

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 .../devicetree/bindings/net/ieee802154/cc2520.txt  |   29 ++++++++++++++++++++
 1 file changed, 29 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt

diff --git a/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
new file mode 100644
index 0000000..6b41f78
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
@@ -0,0 +1,29 @@
+*CC2520 IEEE 802.15.4 Compatible Radio*
+
+Required properties:
+	- compatible: 		should be "ti,cc2520"
+	- spi-max-frequency:	maximal bus speed (8000000), should be set to 4000000 depends
+			     	sync or async operation mode
+	- reg:			the chipselect index
+	- pinctrl-0: 		pin control group to be used for this controller.
+	- pinctrl-names: 	must contain a "default" entry.
+	- fifo-gpio:		GPIO spec for the FIFO pin
+	- fifop-gpio:		GPIO spec for the FIFOP pin
+	- sfd-gpio:		GPIO spec for the SFD pin
+	- cca-gpio:		GPIO spec for the CCA pin
+	- vreg-gpio:		GPIO spec for the VREG pin
+	- reset-gpio:		GPIO spec for the RESET pin
+Example:
+	cc2520@0 {
+		compatible = "ti,cc2520";
+		reg = <0>;
+		spi-max-frequency = <4000000>;
+		pinctrl-names = "default";
+		pinctrl-0 = <&cc2520_cape_pins>;
+		fifo-gpio = <&gpio1 18 0>;
+		fifop-gpio = <&gpio1 19 0>;
+		sfd-gpio = <&gpio1 13 0>;
+		cca-gpio = <&gpio1 16 0>;
+		vreg-gpio = <&gpio0 31 0>;
+		reset-gpio = <&gpio1 12 0>;
+	};
-- 
1.7.9.5
