From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v4 0/7] net: use platform_{get,set}_drvdata()
Date: Mon, 19 Aug 2013 19:58:17 +0800
Message-ID: <52120859.7060200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
	<leoli@freescale.com>, <linuxppc-dev@lists.ozlabs.org>,
	<pantelis.antoniou@gmail.com>, <vbordug@ru.mvista.com>,
	Greg KH <gregkh@linuxfoundation.org>, <jg1.han@samsung.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25443 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab3HSL64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 07:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

changelog v4:
	remove modify about happy_meal_pci_probe && happy_meal_pci_remove
changelog v3:
	remove modify about dev_set_drvdata()
changelog v2:
	this version add modify record about dev_set_drvdata().

Libo Chen (7):
  net: fsl_pq_mdio: use platform_{get,set}_drvdata()
  net: ucc_geth: use platform_{get,set}_drvdata()
  net: fec_mpc52xx_phy: use platform_{get,set}_drvdata()
  net: sunbmac: use platform_{get,set}_drvdata()
  net: sunhme: use platform_{get,set}_drvdata()
  net: xilinx_emaclite: use platform_{get,set}_drvdata()
  net: davinci_mdio: use platform_{get,set}_drvdata()

 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c |    3 +--
 drivers/net/ethernet/freescale/fsl_pq_mdio.c     |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.c        |    3 +--
 drivers/net/ethernet/sun/sunbmac.c               |    2 +-
 drivers/net/ethernet/sun/sunhme.c                |    2 +-
 drivers/net/ethernet/ti/davinci_mdio.c           |    3 +--
 drivers/net/ethernet/xilinx/xilinx_emaclite.c    |    3 +--
 7 files changed, 7 insertions(+), 11 deletions(-)
