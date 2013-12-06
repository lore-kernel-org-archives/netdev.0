From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 06/10] ARM: dts: sun7i: Add pin muxing options
 for the GMAC
Date: Sat,  7 Dec 2013 01:29:39 +0800
Message-ID: <1386350983-13281-7-git-send-email-wens@csie.org>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-sunxi+bncBCMILY6JWQBBBS4TRCKQKGQEF6XZICY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1386350983-13281-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

The A20 has EMAC and GMAC muxed on the same pins.
Add pin sets with gmac function for MII and RGMII mode to the DTSI.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 arch/arm/boot/dts/sun7i-a20.dtsi | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/arm/boot/dts/sun7i-a20.dtsi b/arch/arm/boot/dts/sun7i-a20.dtsi
index ebb2cce..64b1391 100644
--- a/arch/arm/boot/dts/sun7i-a20.dtsi
+++ b/arch/arm/boot/dts/sun7i-a20.dtsi
@@ -246,6 +246,28 @@
 				allwinner,drive = <0>;
 				allwinner,pull = <0>;
 			};
+
+			gmac_pins_mii: gmac_mii {
+				allwinner,pins = "PA0", "PA1", "PA2",
+						"PA3", "PA4", "PA5", "PA6",
+						"PA7", "PA8", "PA9", "PA10",
+						"PA11", "PA12", "PA13", "PA14",
+						"PA15", "PA16";
+				allwinner,function = "gmac";
+				allwinner,drive = <3>;
+				allwinner,pull = <0>;
+			};
+
+			gmac_pins_rgmii: gmac_rgmii {
+				allwinner,pins = "PA0", "PA1", "PA2",
+						"PA3", "PA4", "PA5", "PA6",
+						"PA7", "PA8", "PA10",
+						"PA11", "PA12", "PA13",
+						"PA15", "PA16";
+				allwinner,function = "gmac";
+				allwinner,drive = <3>;
+				allwinner,pull = <0>;
+			};
 		};
 
 		timer@01c20c00 {
-- 
1.8.5.1
