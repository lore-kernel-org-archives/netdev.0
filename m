From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 0/8] Bug fixes & Code improvements in HNS driver
Date: Thu, 31 Aug 2017 21:39:01 +0800
Message-ID: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set introduces some bug fixes and code improvements.
These have been identified during internal review or testing of
the driver by internal Hisilicon teams.

Lipeng (8):
  net: hns3: add check when initialize
  net: hns3: update ring and vector map command
  net: hns3: set default mac vlan mask
  net: hns3: set default vlan id to PF
  net: hns3: set the VLAN Ethernet type to HW
  net: hns3: fix bug of reuse command description
  net: hns3: add vlan filter config of Ports
  net: hns3: reimplemmentation of pkt buffer allocation

 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |   5 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |   9 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  64 ++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 613 +++++++++++++--------
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  16 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  |  84 ++-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |   9 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |   9 +
 8 files changed, 541 insertions(+), 268 deletions(-)

-- 
1.9.1
