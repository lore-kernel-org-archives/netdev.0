From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 02/11] doc: dt: add documentation for nxp,lpc1850-dwmac
Date: Thu, 14 May 2015 12:10:57 +0200
Message-ID: <1431598266-25736-3-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33415 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932490AbbENKLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:42 -0400
Received: by layy10 with SMTP id y10so60495843lay.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:41 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add device tree binding documentation for nxp,lpc1850-dwmac.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../devicetree/bindings/net/nxp,lpc1850-dwmac.txt    | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt b/Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
new file mode 100644
index 000000000000..7edba1264f6f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
@@ -0,0 +1,20 @@
+* NXP LPC1850 GMAC ethernet controller
+
+This device is a platform glue layer for stmmac.
+Please see stmmac.txt for the other unchanged properties.
+
+Required properties:
+ - compatible:  Should contain "nxp,lpc1850-dwmac"
+
+Examples:
+
+mac: ethernet@40010000 {
+	compatible = "nxp,lpc1850-dwmac", "snps,dwmac-3.611", "snps,dwmac";
+	reg = <0x40010000 0x2000>;
+	interrupts = <5>;
+	interrupt-names = "macirq";
+	clocks = <&ccu1 CLK_CPU_ETHERNET>;
+	clock-names = "stmmaceth";
+	resets = <&rgu 22>;
+	reset-names = "stmmaceth";
+}
-- 
1.8.0
