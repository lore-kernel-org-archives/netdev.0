From: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH v2 2/3] ARM: dts: stm32f429: Fix Ethernet node on Eval Board
Date: Mon, 24 Oct 2016 10:40:05 +0200
Message-ID: <1477298406-22805-3-git-send-email-alexandre.torgue@st.com>
References: <1477298406-22805-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477298406-22805-1-git-send-email-alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"phy-handle" entry is mandatory when mdio subnode is used in
Ethernet node.

Signed-off-by: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>

diff --git a/arch/arm/boot/dts/stm32429i-eval.dts b/arch/arm/boot/dts/stm32429i-eval.dts
index fa30bf1..a11b108 100644
--- a/arch/arm/boot/dts/stm32429i-eval.dts
+++ b/arch/arm/boot/dts/stm32429i-eval.dts
@@ -99,7 +99,7 @@
 	pinctrl-0	= <&ethernet_mii>;
 	pinctrl-names	= "default";
 	phy-mode	= "mii";
-
+	phy-handle	= <&phy1>;
 	mdio0 {
 		#address-cells = <1>;
 		#size-cells = <0>;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
