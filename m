From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 09/18] arm: sun8i: orangepi-2: Enable dwmac-sun8i
Date: Wed, 12 Apr 2017 13:13:51 +0200
Message-ID: <20170412111400.2296-10-clabbe.montjoie@gmail.com>
References: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBAMZXDDQKGQEEOGLQ6Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170412111400.2296-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The dwmac-sun8i hardware is present on the Orange PI 2.
It uses the internal PHY.

This patch create the needed emac node.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
index 5b6d145..3f54b12 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
@@ -55,6 +55,7 @@
 		serial0 = &uart0;
 		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
 		ethernet1 = &rtl8189;
+		ethernet0 = &emac;
 	};
 
 	chosen {
@@ -203,3 +204,10 @@
 	usb1_vbus-supply = <&reg_usb1_vbus>;
 	status = "okay";
 };
+
+&emac {
+	phy-handle = <&int_mii_phy>;
+	phy-mode = "mii";
+	allwinner,leds-active-low;
+	status = "okay";
+};
-- 
2.10.2
