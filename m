From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 0/7] net: hns3: bug fixes & code improvements
Date: Mon, 23 Oct 2017 19:51:00 +0800
Message-ID: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces various HNS3 bug fixes, optimizations and code
improvements.

Lipeng (7):
  net: hns3: fix a bug when alloc new buffer
  net: hns3: fix the bug when map buffer fail
  net: hns3: fix the ops check in hns3_get_rxnfc
  net: hns3: get vf count by pci_sriov_get_totalvfs
  net: hns3: fix the TX/RX ring.queue_index in hns3_ring_get_cfg
  net: hns3: remove redundant memset when alloc buffer
  net: hns3: fix a bug about hns3_clean_tx_ring

 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c  |  3 ++-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c   | 16 +++++++---------
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h   |  2 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c    |  2 +-
 4 files changed, 11 insertions(+), 12 deletions(-)

-- 
1.9.1
