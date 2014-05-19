From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH 0/3] add hix5hd2 mac driver
Date: Mon, 19 May 2014 20:57:04 +0800
Message-ID: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50731 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbaESM6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 08:58:00 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so5713291pab.6
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 05:57:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhangfei Gao (3):
  hix5hd2-clock: add complex clk
  Documentation: add Device tree bindings for Hisilicon hix5hd2
    ethernet
  net: hisilicon: add hix5hd2 mac driver

 .../bindings/net/hisilicon-hix5hd2-net.txt         |   37 +
 drivers/clk/hisilicon/clk-hix5hd2.c                |  182 ++++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/hisilicon/Kconfig             |   27 +
 drivers/net/ethernet/hisilicon/Makefile            |    5 +
 drivers/net/ethernet/hisilicon/hix5hd2.c           | 1078 ++++++++++++++++++++
 include/dt-bindings/clock/hix5hd2-clock.h          |    9 +
 8 files changed, 1340 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hix5hd2.c

-- 
1.7.9.5
