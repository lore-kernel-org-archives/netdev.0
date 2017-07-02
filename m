From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/6] net: stmmac: revert "support future
 possible different internal phy mode"
Date: Sun,  2 Jul 2017 14:31:53 +0200
Message-ID: <20170702123159.6939-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	andre.przywara-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBPWQ4PFAKGQE2NLL62A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hello

The current way to find if the phy is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the internal one.

My first idea was to use phy-mode = "internal" but since internal phy-mode
is reserved for non-xMII protocol we cannot use it with dwmac-sun8i

I will send an additionnal patch for documenting more phy-mode = "internal"

Corentin Labbe (6):
  arm: sun8i: nanopi-neo: revert use internal phy-mode
  arm: sun8i: orangepi-2: revert "use internal phy-mode"
  arm: sun8i: orangepi-one: revert "use internal phy-mode"
  arm: sun8i: orangepi-zero: revert "use internal phy-mode"
  arm: sun8i: orangepipc: revert "use internal phy-mode"
  net: stmmac: revert "support future possible different internal phy
    mode"

 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts |  2 +-
 arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  2 +-
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  2 +-
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  2 +-
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 10 +++-------
 6 files changed, 8 insertions(+), 12 deletions(-)

-- 
2.13.0
