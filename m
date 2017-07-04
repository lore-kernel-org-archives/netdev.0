From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH net 0/3] Bugfixs for hns ethernet driver
Date: Tue, 4 Jul 2017 18:47:30 +0800
Message-ID: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
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

This patchset fix skb uesd after used, C45 op code and
Tx description filling issues in hns driver.

Yunsheng Lin (3):
  net: hns: Add TX CSUM check when fill TX description
  net: hns: Fix a wrong op phy C45 code
  net: hns: Fix a skb used after free bug

 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 58 ++++++++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h |  8 ++--
 drivers/net/ethernet/hisilicon/hns_mdio.c     |  2 +-
 3 files changed, 40 insertions(+), 28 deletions(-)

-- 
1.9.1
