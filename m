From: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [Patch v2 net-next 00/12] net: fec: imx6sx multiqueue support
Date: Wed, 10 Sep 2014 04:15:31 +0800
Message-ID: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches enable i.MX6SX multi queue support.
i.MX6SX support 3 queue and AVB feature.

Change from v1 to v2.
 - Change num_tx_queue to unsigned int
 - Avoid block non-dt platform
 - remove call netif_set_real_num_rx_queues
 - seperate multi queue patch two part, one is tx and rx handle, with fixed queue 0
   then other one is initilized multiqueue
 - use two difference alignment for tx and rx path

Frank Li (4):
  net: fec: init multi queue date structure
  net: fec: add enet-avb IP support
  ARM: Documentation: Update fec dts binding doc
  ARM: dts: imx6sx: add multi-queue support enet

Fugang Duan (8):
  net:fec: add enet refrence clock for i.MX 6SX chip
  net:fec: add enet AVB feature macro define for imx6sx
  net: fec: change data structure to support multiqueue
  net: fec: parser max queue number from dt file
  net:fec: Disable enet-avb MAC instead of reset MAC
  net:fec: Add fsl,imx6sx-fec  compatible strings
  net: fec: change FEC alignment according to i.mx6 sx requirement
  net: fec: init complete variable in early to avoid kernel dump

 Documentation/devicetree/bindings/net/fsl-fec.txt |   6 +
 arch/arm/boot/dts/imx6sx.dtsi                     |   2 +
 drivers/net/ethernet/freescale/fec.h              | 154 +++-
 drivers/net/ethernet/freescale/fec_main.c         | 848 ++++++++++++++++------
 4 files changed, 751 insertions(+), 259 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
