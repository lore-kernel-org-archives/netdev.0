From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 0/5] Support set_ringparam and {set|get}_rxnfc ethtool commands
Date: Tue, 10 Oct 2017 16:42:02 +0800
Message-ID: <1507624927-98008-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1, Patch [1/5,2/5] add support for ethtool ops set_ringparam
   (ethtool -G) and fix related bug.
2, Patch [3/5,4/5, 5/5] add support for ethtool ops
   set_rxnfc/get_rxnfc (-n/-N) and fix related bug. 

Lipeng (5):
  net: hns3: fixes the ring index in hns3_fini_ring
  net: hns3: add support for set_ringparam
  net: hns3: add support for set_rxnfc
  net: hns3: add support for ETHTOOL_GRXFH
  net: hns3: fix the ring count for ETHTOOL_GRXRINGS

 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |   4 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |   9 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |   1 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 159 ++++++++++++++++++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |   8 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |   6 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   4 +
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  |  95 +++++++++++-
 8 files changed, 280 insertions(+), 6 deletions(-)

-- 
1.9.1
