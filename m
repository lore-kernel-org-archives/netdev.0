From: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Fri, 13 May 2016 14:56:08 +0530
Message-ID: <1463131568-36948-2-git-send-email-harinik@xilinx.com>
References: <1463131568-36948-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463131568-36948-1-git-send-email-harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add documentations for macb mdio driver.

Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/macb-mdio.txt          |   31 ++++++++++++++++++++
 1 file changed, 31 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/macb-mdio.txt

diff --git a/Documentation/devicetree/bindings/net/macb-mdio.txt b/Documentation/devicetree/bindings/net/macb-mdio.txt
new file mode 100644
index 0000000..11c70a3
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/macb-mdio.txt
@@ -0,0 +1,31 @@
+* Cadence MACB MDIO controller
+
+Required properties:
+- compatible: Should be "cdns,macb-mdio"
+- reg: Address and length of the register set of MAC to be used
+- clock-names: Tuple listing input clock names.
+	Required elements: 'pclk', 'hclk'
+	Optional elements: 'tx_clk'
+- clocks: Phandles to input clocks.
+
+Examples:
+
+	mdio {
+		compatible = "cdns,macb-mdio";
+		reg = <0x0 0xff0b0000 0x0 0x1000>;
+		clocks = <&clk125>, <&clk125>, <&clk125>;
+		clock-names = "pclk", "hclk", "tx_clk";
+		ethernet_phyC: ethernet-phy@C {
+			reg = <C>;
+		};
+		ethernet_phy7: ethernet-phy@7 {
+			reg = <7>;
+		};
+		ethernet_phy3: ethernet-phy@3 {
+			reg = <3>;
+		};
+		ethernet_phy8: ethernet-phy@8 {
+			reg = <8>;
+		};
+	};
+
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
