From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 0/7] Bug fixes for the HNS3 Ethernet Driver for Hip08 SoC
Date: Tue, 19 Sep 2017 02:06:21 +0100
Message-ID: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set presents some bug fixes for the HNS3 Ethernet driver, identified
during internal testing & stabilization efforts.

This patch series is meant for Linux 4.14 kernel. 

Lipeng (6):
  net: hns3: get phy addr from NCL_config
  net: hns3: fix the command used to unmap ring from vector
  net: hns3: Fix ring and vector map command
  net: hns3: fix a bug of set mac address
  net: hns3: set default vlan id to PF
  net: hns3: Fixes the premature exit of loop when matching clients

Salil Mehta (1):
  net: hns3: fixes the ether address copy with more appropriate API

 drivers/net/ethernet/hisilicon/hns3/hnae3.c        | 43 +++++-----------------
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  8 +++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 20 ++++++++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  7 ++--
 4 files changed, 35 insertions(+), 43 deletions(-)

-- 
2.11.0
