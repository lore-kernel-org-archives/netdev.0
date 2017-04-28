From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net-next v5 0/2] net: hns: bug fix for HNS driver
Date: Fri, 28 Apr 2017 14:49:45 +0800
Message-ID: <1493362187-51671-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <matthias.bgg@gmail.com>,
        <yankejian@huawei.com>, <lipeng321@huawei.com>,
        <zhouhuiru@huawei.com>, <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5832 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S939416AbdD1G36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 02:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

This patchset add support defered dsaf probe when mdio and
mbigen module is not insmod.

For more details, please refer to individual patch.

change log:
V4 - > V5:
1. Float on net-next;
2. Delete patch "net: hns: fixed bug that skb used after kfree"
   from this patchset;

V3 -> V4:
1. Delete redundant commit message;
2. Add Reviewed-by: Matthias Brugger <mbrugger@suse.com>;

V2 -> V3:
1. Check return value when  platform_get_irq in hns_rcb_get_cfg;

V1 -> V2:
1. Return appropriate errno in hns_mac_register_phy;

lipeng (2):
  net: hns: support deferred probe when can not obtain irq
  net: hns: support deferred probe when no mdio

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 39 +++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  4 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c |  8 ++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |  2 +-
 4 files changed, 44 insertions(+), 9 deletions(-)

-- 
1.9.1
