From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code Improvements
Date: Thu, 30 Mar 2017 16:30:47 +0100
Message-ID: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set introduces various HNS bug fixes, optimizations and code
improvements.

Daode Huang (1):
  net: hns: bug fix of ethtool show the speed

Kejian Yan (7):
  net: hns: Remove the redundant adding and deleting mac function
  net: hns: Remove redundant mac_get_id()
  net: hns: Remove redundant mac table operations
  net: hns: Clean redundant code from hns_mdio.c file
  net: hns: Optimise the code in hns_mdio_wait_ready()
  net: hns: Simplify the exception sequence in hns_ppe_init()
  net: hns: Adjust the SBM module buffer threshold

Salil Mehta (1):
  net: hns: Some checkpatch.pl script & warning fixes

lipeng (10):
  net: hns: Fix the implementation of irq affinity function
  net: hns: Modify GMAC init TX threshold value
  net: hns: Optimize the code for GMAC pad and crc Config
  net: hns: Change the TX queue selection algorithm
  net: hns: Remove redundant memset during buffer release
  net: hns: Optimize hns_nic_common_poll for better performance
  net: hns: Fix to adjust buf_size of ring according to mtu
  net: hns: Replace netif_tx_lock to ring spin lock
  net: hns: Correct HNS RSS key set function
  net: hns: Avoid Hip06 chip TX packet line bug

 drivers/net/ethernet/hisilicon/hns/hnae.c          |   7 +-
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  49 ++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 132 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  61 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  41 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   5 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 249 +----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  14 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  17 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 143 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |  26 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   6 +-
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  13 -
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 463 +++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   3 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |  34 +-
 drivers/net/ethernet/hisilicon/hns_mdio.c          |  20 +-
 17 files changed, 723 insertions(+), 560 deletions(-)

-- 
2.7.4
