From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 0/9] TM related bugfixes for the HNS3 Ethernet Driver
Date: Wed, 20 Sep 2017 18:52:49 +0800
Message-ID: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set contains a few bugfixes related to hclge_tm module.

Yunsheng Lin (9):
  net: hns3: Cleanup for ROCE capability flag in ae_dev
  net: hns3: Fix initialization when cmd is not supported
  net: hns3: Fix for DEFAULT_DV when dev doesn't support DCB
  net: hns3: Fix for not setting rx private buffer size to zero
  net: hns3: Fix for rx_priv_buf_alloc not setting rx shared buffer
  net: hns3: Fix for rx priv buf allocation when DCB is not supported
  net: hns3: Fix typo error for feild in hclge_tm
  net: hns3: Fix for setting rss_size incorrectly
  net: hns3: Fix for pri to tc mapping in TM

 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  15 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |   4 +-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 163 +++++++++++----------
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |   3 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  |  41 +++---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |   4 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  16 +-
 7 files changed, 143 insertions(+), 103 deletions(-)

-- 
1.9.1
