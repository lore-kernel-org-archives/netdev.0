From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v5 3/3] devicetree: add device tree bindings for cc2520 driver
Date: Thu, 19 Jun 2014 14:08:50 +0530
Message-ID: <1403167131-22092-4-git-send-email-varkab@cdac.in>
References: <1403167131-22092-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	sowjanyap@cdac.in, santoshk@cdac.in, venkatas@cdac.in,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403167131-22092-1-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
