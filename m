From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH 1/4] dt-bindings: net-next: Add DT bindings
 documentation for Allwinner V3s EMAC
Date: Sat, 17 Jun 2017 22:07:34 +0800
Message-ID: <20170617140737.41951-2-icenowy@aosc.io>
References: <20170617140737.41951-1-icenowy@aosc.io>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBA7QSTFAKGQEANEB7UI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170617140737.41951-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Allwinner V3s SoC has a Ethernet MAC like the one in Allwinner H3, but
have no external MII capability. That means that it can only use the
EPHY and cannot do Gbps transmission.

Add binding for it.

Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
---
 Documentation/devicetree/bindings/net/dwmac-sun8i.txt | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
index 08e708c73193..725f3b187886 100644
--- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -7,6 +7,7 @@ Required properties:
 - compatible: should be one of the following string:
 		"allwinner,sun8i-a83t-emac"
 		"allwinner,sun8i-h3-emac"
+		"allwinner,sun8i-v3s-emac"
 		"allwinner,sun50i-a64-emac"
 - reg: address and length of the register for the device.
 - interrupts: interrupt for the device
@@ -22,6 +23,7 @@ Required properties:
 - syscon: A phandle to the syscon of the SoC with one of the following
  compatible string:
   - allwinner,sun8i-h3-system-controller
+  - allwinner,sun8i-v3s-system-controller
   - allwinner,sun50i-a64-system-controller
   - allwinner,sun8i-a83t-system-controller
 
@@ -31,7 +33,9 @@ Optional properties:
 Both delay properties need to be a multiple of 100. They control the delay for
 external PHY.
 
-Optional properties for "allwinner,sun8i-h3-emac":
+Optional properties for the following compatibles:
+  - "allwinner,sun8i-h3-emac",
+  - "allwinner,sun8i-v3s-emac":
 - allwinner,leds-active-low: EPHY LEDs are active low
 
 Required child node of emac:
@@ -44,7 +48,9 @@ Required properties of the mdio node:
 The device node referenced by "phy" or "phy-handle" should be a child node
 of the mdio node. See phy.txt for the generic PHY bindings.
 
-Required properties of the phy node with "allwinner,sun8i-h3-emac":
+Required properties of the phy node with the following compatibles:
+  - "allwinner,sun8i-h3-emac",
+  - "allwinner,sun8i-v3s-emac":
 - clocks: a phandle to the reference clock for the EPHY
 - resets: a phandle to the reset control for the EPHY
 
-- 
2.13.0
