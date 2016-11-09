From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 00/17] Bug fixes & Code improvements in HNS driver
Date: Wed, 9 Nov 2016 18:13:44 +0000
Message-ID: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set introduces some bug fixes and code improvements.
These have been identified during internal review or testing of
the driver by internal Hisilicon teams.

Daode Huang (3):
  net: hns: set default mac pause time to 0xffff
  net: hns: bug fix about restart auto-negotiation
  net: hns: fix to intimate the link-status change by adding LF/RF
    method

Kejian Yan (5):
  Doc: hisi: hns adds mc-mac-mask property
  net: hns: add fuzzy match of tcam table for hns
  net: hns: fix for promisc mode in HNS driver
  net: hns: add multicast tcam table clear
  net: hns: add the support to add/remove the ucast entry to/from table

Qianqian Xie (9):
  net: hns: delete redundant macro definition
  net: hns: modify ethtool statistics value error
  net: hns: modify buffer format of cpu data to le64
  net: hns: modify tcam table and set mac key
  net: hns: modify tcam table of mac uc-entry
  net: hns: modify table index to get mac entry
  net: hns: modify tcam table of mac mc-port
  net: hns: modify tcam table of mac mc-entry
  net: hns: modify tcam table of mask_key

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |    8 +
 drivers/net/ethernet/hisilicon/hns/hnae.h          |   17 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   38 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |    4 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   70 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   17 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  411 +++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   31 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   31 --
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   13 +-
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |   41 +-
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h    |    5 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |   30 ++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |    3 +-
 14 files changed, 577 insertions(+), 142 deletions(-)

-- 
1.7.9.5
