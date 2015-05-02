From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 2/2] doc: dt: add documentation for nxp,lpc1850-dwmac
Date: Sat,  2 May 2015 18:40:42 +0200
Message-ID: <1430584842-23408-3-git-send-email-manabian@gmail.com>
References: <1430584842-23408-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:36516 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbbEBQlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 12:41:49 -0400
Received: by lbbqq2 with SMTP id qq2so81331321lbb.3
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 09:41:47 -0700 (PDT)
In-Reply-To: <1430584842-23408-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
