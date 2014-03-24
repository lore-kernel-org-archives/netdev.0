From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v3 0/3] add hisilicon hip04 ethernet driver
Date: Mon, 24 Mar 2014 22:14:53 +0800
Message-ID: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, linux@arm.linux.org.uk, arnd@arndb.de,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56686 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbaCXOPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 10:15:05 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so5502745pad.21
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 07:15:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:
Suggest from Arnd, use syscon & regmap_write/read to replace static void __iomem *ppebase.
Modify hisilicon-hip04-net.txt accrordingly to suggestion from Florian and Sergei.

v2:
Got many suggestions from Russell, Arnd, Florian, Mark and Sergei
Remove memcpy, use dma_map/unmap_single, use dma_alloc_coherent rather than dma_pool, etc.
Refer property in ethernet.txt, change ppe description, etc.

Zhangfei Gao (3):
  Documentation: add Device tree bindings for Hisilicon hip04 ethernet
  net: hisilicon: new hip04 MDIO driver
  net: hisilicon: new hip04 ethernet driver

 .../bindings/net/hisilicon-hip04-net.txt           |  110 +++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/hisilicon/Kconfig             |   32 +
 drivers/net/ethernet/hisilicon/Makefile            |    5 +
 drivers/net/ethernet/hisilicon/hip04_eth.c         |  728 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hip04_mdio.c        |  186 +++++
 7 files changed, 1063 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c

-- 
1.7.9.5
