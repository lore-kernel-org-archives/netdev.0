From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V2 RE-SEND 0/7] add new Samsung SXGbE driver
Date: Thu, 13 Mar 2014 15:55:28 +0900
Message-ID: <007901cf3e89$37d632e0$a78298a0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This is 2nd posting for Samsung SXGbE driver and just re-sending because of
line wrapping in previous posting.

Changes since v1:
- changed name of driver to SXGbE as per Ben's comment
- squashed Joe's neatening for many stuff in original patches

Byungho An (1):
      MAINTAINERS: add maintainer for Samsung sxgbe driver

Girish K S (2):
      net: sxgbe: add EEE(Energy Efficient Ethernet) for Samsung sxgbe
      net: sxgbe: add WOL(Wakeup-On-Lan)support for Samsung sxgbe

Siva Reddy (1):
      net: sxgbe: add basic framework for Samsung 10Gb ethernet driver

Vipul Pandya (3):
      net: sxgbe: add TSO support for Samsung sxgbe
      net: sxgbe: add Checksum offload support for Samsung sxgbe
      net: sxgbe: add ethtool related functions support Samsung sxgbe

 .../devicetree/bindings/net/samsung-sxgbe.txt      |   39 +
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |    7 +
 drivers/net/ethernet/samsung/Makefile              |    4 +
 drivers/net/ethernet/samsung/sxgbe_common.h        |  571 +++++
 drivers/net/ethernet/samsung/sxgbe_core.c          |  290 +++
 drivers/net/ethernet/samsung/sxgbe_desc.c          |  515 ++++
 drivers/net/ethernet/samsung/sxgbe_desc.h          |  298 +++
 drivers/net/ethernet/samsung/sxgbe_dma.c           |  381 +++
 drivers/net/ethernet/samsung/sxgbe_dma.h           |   51 +
 drivers/net/ethernet/samsung/sxgbe_ethtool.c       |  628 +++++
 drivers/net/ethernet/samsung/sxgbe_main.c          | 2447
++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe_mdio.c          |  274 +++
 drivers/net/ethernet/samsung/sxgbe_mtl.c           |  279 +++
 drivers/net/ethernet/samsung/sxgbe_mtl.h           |  108 +
 drivers/net/ethernet/samsung/sxgbe_platform.c      |  272 +++
 drivers/net/ethernet/samsung/sxgbe_reg.h           |  491 ++++
 drivers/net/ethernet/samsung/sxgbe_xpcs.c          |   92 +
 drivers/net/ethernet/samsung/sxgbe_xpcs.h          |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 22 files changed, 6850 insertions(+)

Thanks,
Byungho An
