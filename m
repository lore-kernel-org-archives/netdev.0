From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 0/5] net: phy: sun8i-h3-ephy: Add Allwinner H3 Ethernet PHY driver
Date: Tue,  5 Apr 2016 00:22:29 +0800
Message-ID: <1459786954-12649-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi everyone,

This is an attempt to support the Ethernet PHY incorporated in Allwinner's
H3 SoC. It is a MII PHY, supporting 10/100 Mbps Ethernet.

Before the PHY can be accessed via MDIO and used, it needs to be powered
on and configured. This is done via a system control register in the CPU
address space. The same register also controls PHY interface mode and
MAC TX clock sources.

This driver brings up the Ethernet PHY (if it is used), and exports a
clock control for the MAC TX clock.

Patch 1 adds the bindings for this piece of hardware.

Patch 2 adds the driver for it.

Patch 3 adds a device node for the PHY.

Patch 4 & 5 are not to be merged. They are provided here as a solid
example of how this driver is used. The sun8i-emac bindings have not
been submitted and are not stable yet.

Comments welcome.

Regards
ChenYu


Chen-Yu Tsai (4):
  net: phy: sun8i-h3-ephy: Add bindings for Allwinner H3 Ethernet PHY
  net: phy: sun8i-h3-ephy: Add driver for Allwinner H3 Ethernet PHY
  ARM: dts: sun8i-h3: Add H3 Ethernet PHY device node to sun8i-h3.dtsi
  ARM: dts: sun8i: Enable Ethernet controller on the Orange PI PC

LABBE Corentin (1):
  ARM: dts: sun8i-h3: Add Ethernet controller device node to
    sun8i-h3.dtsi

 .../bindings/net/allwinner,sun8i-h3-ephy.txt       |  44 ++++
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |  14 ++
 arch/arm/boot/dts/sun8i-h3.dtsi                    |  21 ++
 drivers/net/phy/Kconfig                            |   8 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/sun8i-h3-ephy.c                    | 266 +++++++++++++++++++++
 6 files changed, 354 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
 create mode 100644 drivers/net/phy/sun8i-h3-ephy.c

-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
