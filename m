From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v3 0/2] add hix5hd2 mac driver
Date: Fri, 30 May 2014 17:02:06 +0800
Message-ID: <1401440528-7804-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:44475 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbaE3JC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 05:02:29 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so1500340pbb.8
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 02:02:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:
Remove .ndo_get_stats as mentioned by Tobias
Add __le32 conversion pointed by Mark

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
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 1066 ++++++++++++++++++++
 6 files changed, 1136 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c

-- 
1.7.9.5
