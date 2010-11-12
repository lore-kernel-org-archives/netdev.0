From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 00/14] Use printf extension %pR for struct resource
Date: Fri, 12 Nov 2010 13:37:50 -0800
Message-ID: <cover.1289597644.git.joe@perches.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Yet more trivia...

Joe Perches (14):
  arch/frv: Use printf extension %pR for struct resource
  arch/mips: Use printf extension %pR for struct resource
  arch/powerpc: Use printf extension %pR for struct resource
  drivers/dma/ppc4xx: Use printf extension %pR for struct resource
  drivers/infiniband: Use printf extension %pR for struct resource
  drivers/mfd: Use printf extension %pR for struct resource
  drivers/mtd/maps: Use printf extension %pR for struct resource
  drivers/mtd/nand: Use printf extension %pR for struct resource
  drivers/net/can/sja1000: Use printf extension %pR for struct resource
  drivers/parisc: Use printf extension %pR for struct resource
  drivers/rapidio: Use printf extension %pR for struct resource
  drivers/uwb: Use printf extension %pR for struct resource
  drivers/video: Use printf extension %pR for struct resource
  sound/ppc: Use printf extension %pR for struct resource

 arch/frv/mb93090-mb00/pci-vdk.c               |    8 ++------
 arch/mips/txx9/generic/pci.c                  |    7 ++-----
 arch/powerpc/kernel/pci_64.c                  |    3 +--
 arch/powerpc/sysdev/tsi108_dev.c              |    8 ++++----
 drivers/dma/ppc4xx/adma.c                     |    5 ++---
 drivers/infiniband/hw/ipath/ipath_driver.c    |    5 ++---
 drivers/mfd/sm501.c                           |    7 ++-----
 drivers/mtd/maps/amd76xrom.c                  |    7 ++-----
 drivers/mtd/maps/ck804xrom.c                  |    7 ++-----
 drivers/mtd/maps/esb2rom.c                    |    9 +++------
 drivers/mtd/maps/ichxrom.c                    |    9 +++------
 drivers/mtd/maps/physmap_of.c                 |    4 +---
 drivers/mtd/maps/scx200_docflash.c            |    5 ++---
 drivers/mtd/nand/pasemi_nand.c                |    2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |    8 ++------
 drivers/parisc/dino.c                         |   13 +++++--------
 drivers/parisc/hppb.c                         |    6 ++----
 drivers/rapidio/rio.c                         |    4 ++--
 drivers/uwb/umc-dev.c                         |    7 ++-----
 drivers/video/platinumfb.c                    |    8 ++------
 sound/ppc/pmac.c                              |   12 ++++--------
 21 files changed, 48 insertions(+), 96 deletions(-)

-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
