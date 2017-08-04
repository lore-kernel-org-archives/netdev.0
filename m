From: Alexandru Gagniuc <alex.g@adaptrum.com>
Subject: [PATCH v2 2/2] dt-bindings: net: Document bindings for anarion-gmac
Date: Fri,  4 Aug 2017 13:08:52 -0700
Message-ID: <20170804200852.16049-2-alex.g@adaptrum.com>
References: <20170728.190155.457209566729295513.davem@davemloft.net>
 <20170804200852.16049-1-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        robh+dt@kernel.org, Alexandru Gagniuc <alex.g@adaptrum.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0080.outbound.protection.outlook.com ([104.47.38.80]:35872
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751272AbdHDUJD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 16:09:03 -0400
In-Reply-To: <20170804200852.16049-1-alex.g@adaptrum.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
---
 .../devicetree/bindings/net/anarion-gmac.txt       | 25 ++++++++++++++++++++++
 1 file changed, 25 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/anarion-gmac.txt

diff --git a/Documentation/devicetree/bindings/net/anarion-gmac.txt b/Documentation/devicetree/bindings/net/anarion-gmac.txt
new file mode 100644
index 0000000..fe67896
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/anarion-gmac.txt
@@ -0,0 +1,25 @@
+*  Adaptrum Anarion ethernet controller
+
+This device is a platform glue layer for stmmac.
+Please see stmmac.txt for the other unchanged properties.
+
+Required properties:
+ - compatible:  Should be "adaptrum,anarion-gmac", "snps,dwmac"
+ - phy-mode:    Should be "rgmii". Other modes are not currently supported.
+
+
+Examples:
+
+	gmac1: ethernet@f2014000 {
+		compatible = "adaptrum,anarion-gmac", "snps,dwmac";
+		reg = <0xf2014000 0x4000>, <0xf2018100 8>;
+
+		interrupt-parent = <&core_intc>;
+		interrupts = <21>;
+		interrupt-names = "macirq";
+
+		clocks = <&core_clk>;
+		clock-names = "stmmaceth";
+
+		phy-mode = "rgmii";
+	};
-- 
2.9.3
