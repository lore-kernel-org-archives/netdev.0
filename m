From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v3 6/6] dt-bindings: net: ks8995: add bindings documentation for ks8995
Date: Tue,  9 Feb 2016 20:47:18 +0100
Message-ID: <1455047238-111358-7-git-send-email-helmut.buchsbaum@gmail.com>
References: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34022 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbcBITrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 14:47:42 -0500
Received: by mail-wm0-f67.google.com with SMTP id p63so5382810wmp.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 11:47:41 -0800 (PST)
In-Reply-To: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
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
+	switch@0 {
+		compatible = "micrel,ksz8795";
+
+		reg = <0>;
+		spi-max-frequency = <50000000>;
+		reset-gpios = <&gpio0 46 GPIO_ACTIVE_LOW>;
+	};
+};
-- 
2.1.4
