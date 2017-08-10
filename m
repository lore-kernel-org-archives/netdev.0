From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v5 00/11] Add the integrated PHY support
Date: Thu, 10 Aug 2017 21:56:39 +0800
Message-ID: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The rk3228 and rk3328 support integrated PHY inside, let's enable
it to work. And the integrated PHY need to do some special setting,
so register the rockchip integrated PHY driver.

David Wu (11):
  net: phy: Add rockchip PHY driver support
  multi_v7_defconfig: Make rockchip PHY built-in
  arm64: defconfig: Enable CONFIG_ROCKCHIP_PHY
  net: stmmac: dwmac-rk: Remove unwanted code for rk3328_set_to_rmii()
  Documentation: net: phy: Add phy-is-integrated binding
  net: stmmac: dwmac-rk: Add integrated PHY support
  net: stmmac: dwmac-rk: Add integrated PHY support for rk3228
  net: stmmac: dwmac-rk: Add integrated PHY supprot for rk3328
  ARM: dts: rk3228-evb: Enable the integrated PHY for gmac
  ARM64: dts: rockchip: Add gmac2phy node support for rk3328
  ARM64: dts: rockchip: Enable gmac2phy for rk3328-evb

 Documentation/devicetree/bindings/net/phy.txt  |   5 +
 arch/arm/boot/dts/rk3228-evb.dts               |  34 ++++
 arch/arm/configs/multi_v7_defconfig            |   1 +
 arch/arm64/boot/dts/rockchip/rk3328-evb.dts    |  17 ++
 arch/arm64/boot/dts/rockchip/rk3328.dtsi       |  39 +++++
 arch/arm64/configs/defconfig                   |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 140 +++++++++++++--
 drivers/net/phy/Kconfig                        |   5 +
 drivers/net/phy/Makefile                       |   1 +
 drivers/net/phy/rockchip.c                     | 233 +++++++++++++++++++++++++
 10 files changed, 466 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/phy/rockchip.c

-- 
1.9.1


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
