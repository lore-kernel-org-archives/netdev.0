From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 0/8] Bug Fixes and Code Improvement in HNS driver
Date: Thu, 29 Sep 2016 18:09:08 +0100
Message-ID: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:53772 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbcI2RKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:10:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set introduces fix to some Bugs, potential problems
and code improvements identified during internal review and
testing of Hisilicon Network Subsystem driver.

Submit Change
V1->V2: This addresses the feedbacks provided by David Miller
        and Doug Ledford

Daode Huang (6):
  net: hns: bug fix about setting coalsecs-usecs to 0
  net: hns: add fini_process for v2 napi process
  net: hns: delete repeat read fbd num after while
  net: hns: fix the bug of forwarding table
  net: hns: bug fix about broadcast/multicast packets
  net: hns: delete redundant broadcast packet filter process

Kejian Yan (1):
  net: hns: fix port not available after testing loopback

lipeng (1):
  net: hns: fix port unavailable after hnae_reserve_buffer_map fail

 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   11 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   13 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |    2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   10 --
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |   16 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    4 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  107 +++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |    7 ++
 9 files changed, 118 insertions(+), 53 deletions(-)

-- 
1.7.9.5
