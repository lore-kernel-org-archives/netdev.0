From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v2 6/6] dt-bindings: net: ks8995: add bindings documentation for ks8995
Date: Mon,  8 Feb 2016 18:35:37 +0100
Message-ID: <1454952937-19428-7-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454952937-19428-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34349 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbcBHRf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 12:35:58 -0500
Received: by mail-wm0-f68.google.com with SMTP id p63so16472267wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 09:35:57 -0800 (PST)
In-Reply-To: <1454952937-19428-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 .../devicetree/bindings/net/micrel-ks8995.txt        | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ks8995.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ks8995.txt b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
new file mode 100644
index 0000000..7f11ca6
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ks8995.txt
@@ -0,0 +1,20 @@
+Micrel KS8995 SPI controlled Ethernet Switch families
+
+Required properties (according to spi-bus.txt):
+- compatible: either "micrel,ks8995", "micrel,ksz8864" or "micrel,ksz8795"
+
+Optional properties:
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
+		reset-gpios = <&gpio0 46 1>;
+	};
+};
-- 
2.1.4
