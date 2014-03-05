From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 0/7] add new Samsung xgmac driver
Date: Wed, 05 Mar 2014 20:28:13 +0900
Message-ID: <007a01cf3865$fefc1760$fcf44620$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series adds Samsung xgmac driver.


Byungho An (1):
      MAINTAINERS: add maintainer for Samsung xgmac driver

Girish K S (2):
      net: xgmac: add EEE(Energy Efficient Ethernet) for Samsung xgmac
      net: xgmac: add WOL(Wakeup-On-Lan)support for Samsung xgmac

Siva Reddy (1):
      net: xgmac: add basic framework for Samsung 10Gb ethernet driver

Vipul Pandya (3):
      net: xgmac: add TSO support for Samsung xgmac
      net: xgmac: add Checksum offload support for Samsung xgmac
      net: xgmac: add ethtool related functions support Samsung xgmac

 .../devicetree/bindings/net/samsung-xgmac.txt      |   39 +
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |    7 +
 drivers/net/ethernet/samsung/Makefile              |    4 +
 drivers/net/ethernet/samsung/xgmac_common.h        |  571 +++++
 drivers/net/ethernet/samsung/xgmac_core.c          |  290 +++
 drivers/net/ethernet/samsung/xgmac_desc.c          |  515 ++++
 drivers/net/ethernet/samsung/xgmac_desc.h          |  298 +++
 drivers/net/ethernet/samsung/xgmac_dma.c           |  381 +++
 drivers/net/ethernet/samsung/xgmac_dma.h           |   51 +
 drivers/net/ethernet/samsung/xgmac_ethtool.c       |  628 +++++
 drivers/net/ethernet/samsung/xgmac_main.c          | 2447 ++++++++++++++++++++
 drivers/net/ethernet/samsung/xgmac_mdio.c          |  274 +++
 drivers/net/ethernet/samsung/xgmac_mtl.c           |  279 +++
 drivers/net/ethernet/samsung/xgmac_mtl.h           |  108 +
 drivers/net/ethernet/samsung/xgmac_platform.c      |  272 +++
 drivers/net/ethernet/samsung/xgmac_reg.h           |  491 ++++
 drivers/net/ethernet/samsung/xgmac_xpcs.c          |   92 +
 drivers/net/ethernet/samsung/xgmac_xpcs.h          |   38 +
 include/linux/xgmac_platform.h                     |   54 +
 22 files changed, 6850 insertions(+)
