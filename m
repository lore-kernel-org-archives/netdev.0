From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V8 0/7] add new Samsung SXGBE driver
Date: Thu, 20 Mar 2014 10:25:54 -0700
Message-ID: <012c01cf4461$75af8f70$610eae50$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:53620 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758738AbaCTR0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:26:04 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is 8th posting for SAMSUNG SXGBE driver.

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

 .../devicetree/bindings/net/samsung-sxgbe.txt      |   60 +
 MAINTAINERS                                        |    9 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |   20 +
 drivers/net/ethernet/samsung/Makefile              |    5 +
 drivers/net/ethernet/samsung/sxgbe/Kconfig         |    9 +
 drivers/net/ethernet/samsung/sxgbe/Makefile        |    4 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |  539 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |  261 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c    |  515 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h    |  298 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c     |  387 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h     |   51 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |  588 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 2316 ++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |  271 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c     |  252 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h     |  104 +
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  262 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |  488 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c    |   92 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h    |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 24 files changed, 6625 insertions(+)

Thanks,
Byungho An
