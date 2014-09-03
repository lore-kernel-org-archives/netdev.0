From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 00/11] net: fec: imx6sx multiqueue support
Date: Thu, 4 Sep 2014 04:34:35 +0800
Message-ID: <42459.8171994605$1409778751@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

These patches enable i.MX6SX multi queue support.
i.MX6SX support 3 queue and AVB feature. 

Frank Li (3):
  net:fec: add enet-avb IP support
  ARM: Documentation: Update fec dts binding doc
  ARM: dts: imx6sx: add multi-queue support enet

Fugang Duan (8):
  net:fec: add enet refrence clock for i.MX 6SX chip
  net:fec: add enet AVB feature macro define for imx6sx
  net:fec: use multiqueue interface to allocate Ethernet device
  net:fec: add multiqueue support
  net:fec: Disable enet-avb MAC instead of reset MAC
  net:fec: Add fsl,imx6sx-fec  compatible strings
  net:fec: change FEC alignment to 64 bytes for ARM platform
  net:fec: remove unnessary memory copy for address alignment in .xmit()

 Documentation/devicetree/bindings/net/fsl-fec.txt |   6 +
 arch/arm/boot/dts/imx6sx.dtsi                     |   2 +
 drivers/net/ethernet/freescale/fec.h              | 151 +++-
 drivers/net/ethernet/freescale/fec_main.c         | 877 +++++++++++++++-------
 4 files changed, 750 insertions(+), 286 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
