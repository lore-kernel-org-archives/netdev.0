From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V3 0/8] add new Samsung SXGBE driver
Date: Mon, 17 Mar 2014 13:43:34 -0700
Message-ID: <00bc01cf4221$9239f6e0$b6ade4a0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This is 3rd posting for SAMSUNG SXGBE driver.

Changes since v1:
- changed name of driver to SXGbE as per Ben's comment
- squashed Joe's neatening for many stuff in original patches

Changes since v2:
- updated and split binding document as per Mark's comment
- clean up codes as per Joe's comment
- removed unused fields and clean up codes as per Francois's comment
- removed module parameters as per Dave's comment
- moved driver directory to samsung/sxgbe/

Byungho An (1):
      MAINTAINERS: add maintainer for Samsung sxgbe driver

Girish K S (2):
      net: sxgbe: add EEE(Energy Efficient Ethernet) for Samsung sxgbe
      net: sxgbe: add WOL(Wakeup-On-Lan)support for Samsung sxgbe

Siva Reddy (2):
      sxgbe: Add device-tree binding support document
      net: sxgbe: add basic framework for Samsung 10Gb ethernet driver

Vipul Pandya (3):
      net: sxgbe: add TSO support for Samsung sxgbe
      net: sxgbe: add Checksum offload support for Samsung sxgbe
      net: sxgbe: add ethtool related functions support Samsung sxgbe

 .../devicetree/bindings/net/samsung-sxgbe.txt      |   53 +
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |   20 +
 drivers/net/ethernet/samsung/Makefile              |    5 +
 drivers/net/ethernet/samsung/sxgbe/Kconfig         |    9 +
 drivers/net/ethernet/samsung/sxgbe/Makefile        |    4 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |  552 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |  290 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c    |  515 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h    |  298 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c     |  387 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h     |   51 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |  633 ++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 2392 ++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |  274 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c     |  282 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h     |  108 +
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  267 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |  491 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c    |   92 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h    |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 24 files changed, 6826 insertions(+)

Thanks,
Byungho An
