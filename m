From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH NET v2 0/2] Add loopback support in phy_driver and hns ethtool fix
Date: Fri, 23 Jun 2017 15:54:31 +0800
Message-ID: <1498204473-194648-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This Patch Set add set_loopback in phy_driver and use it to setup loopback
when doing ethtool phy self_test.

Patch V2:
	1. Add phy_loopback in phy_device.c.
	2. Do error checking and do the read and write once in genphy_loopback.
	3. Remove gen10g_loopback in phy_device.c.

Patch V1: Initial Submit

Lin Yun Sheng (2):
  net: phy: Add phy loopback support in net phy framework
  net: hns: Use phy_driver to setup Phy loopback

 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 68 +++++-------------------
 drivers/net/phy/marvell.c                        |  1 +
 drivers/net/phy/phy_device.c                     | 41 ++++++++++++++
 include/linux/phy.h                              |  5 ++
 4 files changed, 61 insertions(+), 54 deletions(-)

-- 
1.9.1
