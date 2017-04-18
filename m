From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 0/3] net: hns: add deferred probe and fix a bug
Date: Tue, 18 Apr 2017 18:12:31 +0800
Message-ID: <1492510354-11300-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <allenhuangsz10@gmail.com>,
        <lipeng321@huawei.com>, <huangdaode@hisilicon.com>,
        <hjat.hejun@huawei.com>, <zhangping5@huawei.com>,
        <qichengming@huawei.com>, <qumingguang@hisilicon.com>,
        <zhouhuiru@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5770 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754849AbdDRJwX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 05:52:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support defered probe to avoid no mdio scene, and will
fix a bug that skb may be freed several times.

lipeng (3):
  net: hns: support deferred probe when can not obtain irq
  net: hns: support deferred probe when no mdio
  net: hns: fixed bug that skb used after kfree

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 34 ++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 22 +++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |  6 ++--
 4 files changed, 53 insertions(+), 21 deletions(-)

-- 
1.9.1
