From: <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/3] Fix stmmac-socfpga allmodconfig breakage in arm-soc
Date: Tue, 25 Mar 2014 18:34:39 -0500
Message-ID: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
To: <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>

Hi,

These 3 patches are based on Arnd's patch to fix the allmodconfig for the
dwmac-socfpga implementation. I just broke the patch out into drivers,
dts, and dts documentation.

The original patch is here:
http://lists.infradead.org/pipermail/linux-arm-kernel/2014-March/241518.html

Arnd mentioned that he was thinking about just removing the dwmac-socfpga
and send out the new verion to the netdev tree, but I haven't seen it. So
just in case this solution might work, here are the patches.

These patches are based on arm-soc/for-next.

Thanks,

Dinh Nguyen (3):
  net: stmmac: improve binding and fix build
  dts: socfpga: Fix ethernet entries for the stmmac
  dts: documentation: Update documentation for the stmmac ethernet
    controller

 .../devicetree/bindings/net/socfpga-dwmac.txt      |   38 ++++------
 Documentation/devicetree/bindings/net/stmmac.txt   |    6 ++
 arch/arm/boot/dts/socfpga.dtsi                     |   51 +++++---------
 arch/arm/boot/dts/socfpga_arria5_socdk.dts         |    5 +-
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |    5 +-
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |    5 +-
 arch/arm/boot/dts/socfpga_vt.dts                   |    5 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   10 +++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   73 +++-----------------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 +
 12 files changed, 67 insertions(+), 137 deletions(-)

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
