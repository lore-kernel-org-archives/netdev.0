From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 21:24:26 +0800
Message-ID: <5208E20A.4010306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, <timur@freescale.com>,
	<leoli@freescale.com>, <linuxppc-dev@lists.ozlabs.org>,
	<pantelis.antoniou@gmail.com>, <vbordug@ru.mvista.com>,
	Greg KH <gregkh@linuxfoundation.org>, <jg1.han@samsung.com>,
	Bill Pemberton <wfp5p@virginia.edu>, <michal.simek@xilinx.com>,
	<renner@efe-gmbh.de>, <mugunthanvnm@ti.com>,
	<bigeasy@linutronix.de>, <prabhakar.csengg@gmail.com>,
	<b-liu@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18928 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755971Ab3HLNYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 09:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.


Libo Chen (8):
  net: fsl_pq_mdio: use platform_{get,set}_drvdata()
  net: ucc_geth: use platform_{get,set}_drvdata()
  net: fec_mpc52xx_phy: use platform_{get,set}_drvdata()
  net: fs_enet: use platform_{get,set}_drvdata()
  net: sunbmac: use platform_{get,set}_drvdata()
  net: sunhme: use platform_{get,set}_drvdata()
  net: xilinx_emaclite: use platform_{get,set}_drvdata()
  net: davinci_mdio: use platform_{get,set}_drvdata()

 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c   |    4 +---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 -
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |    3 +--
 drivers/net/ethernet/freescale/ucc_geth.c          |    4 +---
 drivers/net/ethernet/sun/sunbmac.c                 |    3 +--
 drivers/net/ethernet/sun/sunhme.c                  |    8 +++-----
 drivers/net/ethernet/ti/davinci_mdio.c             |    4 +---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    4 +---
 8 files changed, 9 insertions(+), 22 deletions(-)
