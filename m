From: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/8] MIPS: BMIPS: name the refclk clock for uart
Date: Wed,  2 Aug 2017 11:34:29 +0200
Message-ID: <20170802093429.12572-9-jonas.gorski@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170802093429.12572-1-jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the clock name to the uart nodes, to name the input clock
properly.

Signed-off-by: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/mips/boot/dts/brcm/bcm3368.dtsi  | 2 ++
 arch/mips/boot/dts/brcm/bcm63268.dtsi | 2 ++
 arch/mips/boot/dts/brcm/bcm6328.dtsi  | 2 ++
 arch/mips/boot/dts/brcm/bcm6358.dtsi  | 2 ++
 arch/mips/boot/dts/brcm/bcm6362.dtsi  | 2 ++
 arch/mips/boot/dts/brcm/bcm6368.dtsi  | 2 ++
 6 files changed, 12 insertions(+)

diff --git a/arch/mips/boot/dts/brcm/bcm3368.dtsi b/arch/mips/boot/dts/brcm/bcm3368.dtsi
index bee855cb8073..772fb42b7730 100644
--- a/arch/mips/boot/dts/brcm/bcm3368.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm3368.dtsi
@@ -82,6 +82,7 @@
 			interrupts = <2>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
@@ -94,6 +95,7 @@
 			interrupts = <3>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
diff --git a/arch/mips/boot/dts/brcm/bcm63268.dtsi b/arch/mips/boot/dts/brcm/bcm63268.dtsi
index 7e6bf2cc0287..b033a23b5e13 100644
--- a/arch/mips/boot/dts/brcm/bcm63268.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm63268.dtsi
@@ -83,6 +83,7 @@
 			interrupts = <5>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
@@ -95,6 +96,7 @@
 			interrupts = <34>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
diff --git a/arch/mips/boot/dts/brcm/bcm6328.dtsi b/arch/mips/boot/dts/brcm/bcm6328.dtsi
index 5633b9d90f55..7c3061ba6d38 100644
--- a/arch/mips/boot/dts/brcm/bcm6328.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm6328.dtsi
@@ -68,6 +68,7 @@
 			interrupt-parent = <&periph_intc>;
 			interrupts = <28>;
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 			status = "disabled";
 		};
 
@@ -77,6 +78,7 @@
 			interrupt-parent = <&periph_intc>;
 			interrupts = <39>;
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 			status = "disabled";
 		};
 
diff --git a/arch/mips/boot/dts/brcm/bcm6358.dtsi b/arch/mips/boot/dts/brcm/bcm6358.dtsi
index f9d8d392162b..ab9d6c268a84 100644
--- a/arch/mips/boot/dts/brcm/bcm6358.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm6358.dtsi
@@ -92,6 +92,7 @@
 			interrupts = <2>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
@@ -104,6 +105,7 @@
 			interrupts = <3>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
diff --git a/arch/mips/boot/dts/brcm/bcm6362.dtsi b/arch/mips/boot/dts/brcm/bcm6362.dtsi
index c507da594f2f..ca93c9a6f23f 100644
--- a/arch/mips/boot/dts/brcm/bcm6362.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm6362.dtsi
@@ -83,6 +83,7 @@
 			interrupts = <3>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
@@ -95,6 +96,7 @@
 			interrupts = <4>;
 
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 
 			status = "disabled";
 		};
diff --git a/arch/mips/boot/dts/brcm/bcm6368.dtsi b/arch/mips/boot/dts/brcm/bcm6368.dtsi
index d0e3a70b32e2..da4ec89710fd 100644
--- a/arch/mips/boot/dts/brcm/bcm6368.dtsi
+++ b/arch/mips/boot/dts/brcm/bcm6368.dtsi
@@ -89,6 +89,7 @@
 			interrupt-parent = <&periph_intc>;
 			interrupts = <2>;
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 			status = "disabled";
 		};
 
@@ -98,6 +99,7 @@
 			interrupt-parent = <&periph_intc>;
 			interrupts = <3>;
 			clocks = <&periph_clk>;
+			clock-names = "refclk";
 			status = "disabled";
 		};
 
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
