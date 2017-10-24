From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 0/4] net: hns3: fix some bugs for HNS3 driver
Date: Tue, 24 Oct 2017 21:02:08 +0800
Message-ID: <1508850132-106101-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes some bugs reported by Hisilicon test team.

Lipeng (4):
  net: hns3: fix the bug of hns3_set_txbd_baseinfo
  net: hns3: add nic_client check when initialize roce base information
  net: hns3: fix a bug in hclge_uninit_client_instance
  net: hns3: fix the bug when reuse command description in
    hclge_add_mac_vlan_tbl

 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 18 ++++++++++++------
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  2 +-
 2 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.9.1
