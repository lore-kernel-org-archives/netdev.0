From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net v2 0/3] net: hns: bug fix for HNS driver
Date: Fri, 21 Apr 2017 15:44:41 +0800
Message-ID: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <lipeng321@huawei.com>,
        <huangdaode@hisilicon.com>, <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5376 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1035950AbdDUHYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 03:24:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

This series adds support defered probe when mdio or mbigen module
insmod behind HNS driver, and fixes a bug that a skb has been
freed, but it may be still used in driver.

change log:
V1 -> V2:
1. Return appropriate errno in hns_mac_register_phy;

lipeng (3):
  net: hns: support deferred probe when can not obtain irq
  net: hns: support deferred probe when no mdio
  net: hns: fixed bug that skb used after kfree

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 39 ++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 22 ++++++------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |  6 ++--
 4 files changed, 58 insertions(+), 21 deletions(-)

-- 
1.9.1
