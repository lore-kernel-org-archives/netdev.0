From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 0/8] net: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 15:05:37 +0800
Message-ID: <1377068737-48616-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <jg1.han@samsung.com>,
	<leoli@freescale.com>, <gregkh@linuxfoundation.org>,
	<linuxppc-dev@lists.ozlabs.org>, <lizefan@huawei.com>,
	<libo.chen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26230 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab3HUHTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 03:19:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Libo Chen (8):
  net: fsl_pq_mdio: remove unnecessary dev_set_drvdata()
  net: ucc_geth: remove unnecessary dev_set_drvdata()
  net: fec_mpc52xx_phy: remove unnecessary dev_set_drvdata()
  net: sunbmac: remove unnecessary dev_set_drvdata()
  net: sunhme: remove unnecessary dev_set_drvdata()
  net: xilinx_emaclite: remove unnecessary dev_set_drvdata()
  net: davinci_mdio: remove unnecessary dev_set_drvdata()
  net: emac: remove unnecessary dev_set_drvdata()

 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c |    1 -
 drivers/net/ethernet/freescale/fsl_pq_mdio.c     |    2 --
 drivers/net/ethernet/freescale/ucc_geth.c        |    1 -
 drivers/net/ethernet/ibm/emac/core.c             |    2 --
 drivers/net/ethernet/sun/sunbmac.c               |    2 --
 drivers/net/ethernet/sun/sunhme.c                |    2 --
 drivers/net/ethernet/ti/davinci_mdio.c           |    2 --
 drivers/net/ethernet/xilinx/xilinx_emaclite.c    |    1 -
 8 files changed, 0 insertions(+), 13 deletions(-)
