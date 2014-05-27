From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v2 0/2] add hix5hd2 mac driver
Date: Tue, 27 May 2014 20:44:25 +0800
Message-ID: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40853 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaE0Mok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 08:44:40 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so9035918pab.6
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 05:44:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
Update binding accoring to Sergei comments
Update descriptor as Arnd's suggestion

Zhangfei Gao (2):
  Documentation: add Device tree bindings for Hisilicon hix5hd2
    ethernet
  net: hisilicon: add hix5hd2 mac driver

 .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/hisilicon/Kconfig             |   27 +
 drivers/net/ethernet/hisilicon/Makefile            |    5 +
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 1062 ++++++++++++++++++++
 6 files changed, 1132 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c

-- 
1.7.9.5
