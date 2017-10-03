From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH v3 0/2] Allwinner XR819 SDIO Wi-Fi DT binding and OPi Zero XR819 IRQ
Date: Wed,  4 Oct 2017 00:59:42 +0800
Message-ID: <20171003165944.13056-1-icenowy@aosc.io>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
        Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Allwinner XR819 SDIO Wi-Fi chip supports an out-of-band interrupt line,
and the in-band interrupt is also supported.

However the current out-of-tree driver uses the out-of-band interrupt by
default.

This patchset adds the device tree binding for the chip as well as the
out-of-band interrupt, then adds the interrupt to the device tree of
Orange Pi Zero.

Icenowy Zheng (1):
  dt-bindings: add device tree binding for Allwinner XR819 SDIO Wi-Fi

Sergey Matyukevich (1):
  ARM: sun8i: h2+: specify wifi interrupts for Orange Pi Zero

 .../bindings/net/wireless/allwinner,xr819.txt      | 38 ++++++++++++++++++++++
 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts  |  3 ++
 2 files changed, 41 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt

-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
