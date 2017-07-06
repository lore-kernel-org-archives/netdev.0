From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH net V2 0/2] Bugfixs for hns ethernet driver
Date: Thu, 6 Jul 2017 10:21:58 +0800
Message-ID: <1499307720-218834-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fix skb used after free and C45 op code issues
in hns driver.

Patch V2:
	1. Remove ndev->feature checking in TX description patch.
	2. Add Fixes: Tag in patch description.

Patch V1:
	Initial Submit

Yunsheng Lin (2):
  net: hns: Fix a wrong op phy C45 code
  net: hns: Fix a skb used after free bug

 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 22 ++++++++++------------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h |  6 +++---
 drivers/net/ethernet/hisilicon/hns_mdio.c     |  2 +-
 3 files changed, 14 insertions(+), 16 deletions(-)

-- 
1.9.1
