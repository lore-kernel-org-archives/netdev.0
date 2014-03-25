From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V14 0/7] add new Samsung SXGBE driver
Date: Tue, 25 Mar 2014 12:10:47 -0700
Message-ID: <01ac01cf485d$f0370610$d0a51230$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:47631 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299AbaCYTK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:10:56 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is 14th posting for SAMSUNG SXGBE driver.

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

Changes since v13:
- clean up error path codes for irqs as per Francois's comment
- removed unsupported functions for ehttoolirq as per Ben's comment

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
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |  538 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |  262 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c    |  515 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h    |  298 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c     |  382 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h     |   50 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |  524 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 2310 ++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |  251 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c     |  254 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h     |  104 +
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  259 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |  488 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c    |   91 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h    |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 24 files changed, 6515 insertions(+)

Thanks,
Byungho An
