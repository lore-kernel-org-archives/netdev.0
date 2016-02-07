From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 7/7] dt-bindings: net: ks8995: add bindings documentation for ks8995
Date: Sun,  7 Feb 2016 23:39:13 +0100
Message-ID: <1454884753-4560-8-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36519 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999AbcBGWkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:40:03 -0500
Received: by mail-wm0-f65.google.com with SMTP id 128so12860347wmz.3
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:40:02 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 .../devicetree/bindings/net/micrel-ks8995.txt      | 27 ++++++++++++++++++++++
 1 file changed, 27 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ks8995.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ks8995.txt b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
new file mode 100644
index 0000000..d178153
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
@@ -0,0 +1,27 @@
+Micrel KS8995 SPI controlled Ethernet Switch families
+
+Required properties (according to spi-bus.txt):
+- compatible: either "micrel,ks8995", "micrel,ksz8864" or "micrel,ksz8795"
+
+Optional properties:
+- settings: list of register initialization triples containing
+            register offset, register value and register mask.
+- reset-gpios : phandle of gpio that will be used to reset chip during probe
+
+Example:
+
+spi-master {
+	...
+	ksz8795 {
+		compatible = "micrel,ksz8795";
+
+		reg = <0>;
+		spi-max-frequency = <50000000>;
+		settings = <
+			0x56 0x10 0x10 /* Enable Ingress RGMII-ID Mode */
+			0x3D 0x08 0x08 /* power down port 3 */
+			0x4D 0x08 0x08 /* power down port 4 */
+		>;
+		reset-gpios = <&gpio0 46 1>;
+	};
+};
-- 
2.1.4
