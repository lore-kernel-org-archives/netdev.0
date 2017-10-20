From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 0/2] Add mac loopback selftest support in hns3 driver
Date: Fri, 20 Oct 2017 10:19:20 +0800
Message-ID: <1508465962-60176-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:8998 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751572AbdJTBcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 21:32:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset refactors the skb receiving and transmitting function
before adding mac loopback selftest support in hns3 driver.

Yunsheng Lin (2):
  net: hns3: Refactor the skb receiving and transmitting function
  net: hns3: Add mac loopback selftest support in hns3 driver

 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    |  54 ++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  17 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   4 +
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 273 +++++++++++++++++++++
 4 files changed, 343 insertions(+), 5 deletions(-)

-- 
1.9.1
