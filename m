From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V13 0/7] add new Samsung SXGBE driver
Date: Sun, 23 Mar 2014 13:46:03 -0700
Message-ID: <009d01cf46d8$efcc5620$cf650260$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This is 13th posting for SAMSUNG SXGBE driver.

Changes since v1:
- changed name of driver to SXGbE as per Ben's comment
- squashed Joe's neatening for many stuff in original patches

Changes since v2:
- updated and split binding document as per Mark's comment
- clean up codes as per Joe's comment
- removed unused fields and clean up codes as per Francois's comment
- removed module parameters as per Dave's comment
- moved driver directory to samsung/sxgbe/

Changes since v3:
- fixed Missing a blank line after declarations as per Dave's comment
- clean up codes as per Joe's comment
- removed reference of net_device.{irq, base_addr} as per Francois's comment

Changes since v4:
- updated binding document and DT related function as per Mark's comment

Changes since v5:
- updated binding document and DT related function as per Florian's comment
- fixed typo and shortened code as per Joe's comment

Changes since v6:
- updated TSO related functions as per Rayagond's comment
- updated binding document as per Mark's comment
- removed WoL patch from this patch set

Changes since v7:
- updated TSO related functions as per Rayagond's comment

Changes since v8:
- removed select and depends statement from vendor sub-section as per 
  Dave's comment

Changes since v9:
- removed adv-add-map, force-sf-dma-modei and force-thresh-dma-mode from 
  binding documnet as per Mark's comment

Changes since v10:
- clean up codes as per Francois's comment

Changes since v11:
- clean up mdio_read/write codes as per Francois's comment
- changed irq acquisition error path as per Francois's comment
- updated mdio and platform related codes as per Tomasz'comment
- clean up dma related codes as per Vince's comment

Changes since v12:
- fixed typo

Byungho An (1):
      MAINTAINERS: add maintainer for Samsung sxgbe driver

Girish K S (1):
      net: sxgbe: add EEE(Energy Efficient Ethernet) for Samsung sxgbe

Siva Reddy (2):
      sxgbe: Add device-tree binding support document
      net: sxgbe: add basic framework for Samsung 10Gb ethernet driver

Vipul Pandya (3):
      net: sxgbe: add TSO support for Samsung sxgbe
      net: sxgbe: add Checksum offload support for Samsung sxgbe
      net: sxgbe: add ethtool related functions support Samsung sxgbe

 .../devicetree/bindings/net/samsung-sxgbe.txt      |   52 +
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |   16 +
 drivers/net/ethernet/samsung/Makefile              |    5 +
 drivers/net/ethernet/samsung/sxgbe/Kconfig         |    9 +
 drivers/net/ethernet/samsung/sxgbe/Makefile        |    4 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |  539 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |  262 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c    |  515 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h    |  298 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c     |  382 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h     |   50 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |  588 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 2310 ++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |  251 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c     |  254 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h     |  104 +
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  254 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |  488 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c    |   91 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h    |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 24 files changed, 6575 insertions(+)

Thanks,
Byungho An
