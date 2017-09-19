From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net 0/7] Bug fixes for the HNS3 Ethernet Driver for Hip08 SoC
Date: Tue, 19 Sep 2017 17:17:09 +0100
Message-ID: <20170919161716.92680-1-salil.mehta@huawei.com>
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

This patch set presents some bug fixes for the HNS3 Ethernet driver identified
during internal testing & stabilization efforts.

Change Log:
Patch V2: Resolved comments from Leon Romanovsky
Patch V1: Initial Submit

Lipeng (6):
  net: hns3: Fixes initialization of phy address from firmware
  net: hns3: Fixes the command used to unmap ring from vector
  net: hns3: Fixes ring-to-vector map-and-unmap command
  net: hns3: Fixes the initialization of MAC address in hardware
  net: hns3: Fixes the default VLAN-id of PF
  net: hns3: Fixes the premature exit of loop when matching clients

Salil Mehta (1):
  net: hns3: Fixes the ether address copy with appropriate API

 drivers/net/ethernet/hisilicon/hns3/hnae3.c        | 43 +++++-----------------
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  8 +++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 20 ++++++++--
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  7 ++--
 4 files changed, 35 insertions(+), 43 deletions(-)

-- 
2.7.4
