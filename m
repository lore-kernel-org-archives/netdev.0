From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 0/2] net: ethernet: hisilicon: set dev->dev.parent before PHY connect
Date: Mon, 12 Dec 2016 20:03:41 +0800
Message-ID: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <xuejiancheng@hisilicon.com>,
        <benjamin.chenhao@hisilicon.com>, <caizhiyong@hisilicon.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series builds atop:
ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461 ("phy: Don't increment MDIO bus
refcount unless it's a different owner")

I have checked all the hisilicon ethernet driver and found only two drivers
need to be fixed to make sure set dev->dev.parent before PHY connect.

Dongpo Li (2):
  net: ethernet: hisi_femac: Call SET_NETDEV_DEV()
  net: ethernet: hip04: Call SET_NETDEV_DEV()

 drivers/net/ethernet/hisilicon/hip04_eth.c  | 2 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
2.8.2
