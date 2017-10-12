From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 0/2] Add mqprio hardware offload support in hns3 driver
Date: Thu, 12 Oct 2017 10:38:30 +0800
Message-ID: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <yuvalm@mellanox.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds a new hardware offload type in mqprio before adding
mqprio hardware offload support in hns3 driver.

Yunsheng Lin (2):
  mqprio: Add a new hardware offload type in mqprio
  net: hns3: Add mqprio hardware offload support in hns3 driver

 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  1 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c | 23 +++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46 ++++++++++++++--------
 include/uapi/linux/pkt_sched.h                     |  1 +
 4 files changed, 55 insertions(+), 16 deletions(-)

-- 
1.9.1
