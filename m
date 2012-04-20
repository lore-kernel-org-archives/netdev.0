From: mathieu.poirier@linaro.org
Subject: [PATCH 0/8] drivers/net: randconfig patches for kernel 3.3
Date: Fri, 20 Apr 2012 14:56:08 -0600
Message-ID: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

These patches fix miscellaneous problems when working
with make randconfig.  They were discovered on kernel
3.1-rc4 and have been reformatted for 3.3.

Arnd Bergmann (8):
  davinci_cpdma: export symbols used by other drivers
  drivers/net: add missing __devexit_p() annotations
  caif: include linux/io.h
  drivers/net: iwmc3200 depends on EXPERIMENTAL
  8390: select CRC32 support
  donauboe: replace excessive udelay with msleep
  sungem: use mdelay instead of udelay where necessary
  drivers/net: decouple ISA and ISA_DMA_API

 drivers/net/caif/caif_shmcore.c           |    4 ++++
 drivers/net/ethernet/8390/Kconfig         |    1 +
 drivers/net/ethernet/micrel/ks8842.c      |    2 +-
 drivers/net/ethernet/sun/sungem.c         |    2 +-
 drivers/net/ethernet/ti/davinci_cpdma.c   |   13 ++++++++++++-
 drivers/net/irda/donauboe.c               |    2 +-
 drivers/net/tokenring/Kconfig             |    6 +++---
 drivers/net/tokenring/tms380tr.c          |    6 +++---
 drivers/net/wimax/i2400m/Kconfig          |    3 ++-
 drivers/net/wireless/b43/sdio.c           |    2 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig |    2 +-
 drivers/net/wireless/p54/p54usb.c         |    2 +-
 12 files changed, 31 insertions(+), 14 deletions(-)

-- 
1.7.5.4
