From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 0/7] A few cleanup for hns3 ethernet driver
Date: Mon, 9 Oct 2017 15:43:54 +0800
Message-ID: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
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

This patchset contains a few cleanup for hns3 ethernet driver.
No functional change intended.

Yunsheng Lin (7):
  net: hns3: Cleanup for shifting true in hns3 driver
  net: hns3: Add hns3_get_handle macro in hns3 driver
  net: hns3: Cleanup indentation for Kconfig in the the hisilicon folder
  net: hns3: Consistently using GENMASK in hns3 driver
  net: hns3: Cleanup for struct that used to send cmd to firmware
  net: hns3: Cleanup for endian issue in hns3 driver
  net: hns3: Cleanup for non-static function in hns3 driver

 drivers/net/ethernet/hisilicon/Kconfig             |   6 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c |  16 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h | 130 +++----
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 385 +++++++++++----------
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |   4 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  |  26 +-
 .../ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c    |  18 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  61 +---
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   3 +
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  |  42 +--
 10 files changed, 344 insertions(+), 347 deletions(-)

-- 
1.9.1
