From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/3] net: make dev_close void
Date: Tue, 18 Jul 2017 15:59:24 -0700
Message-ID: <20170718225927.15944-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36746 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdGRW7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 18:59:31 -0400
Received: by mail-pg0-f50.google.com with SMTP id u5so20180285pgq.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 15:59:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed while working on other changes. Why is dev_close()
returning int, it should be void.  Should also change
ndo_close to be void, but that requires more work and someone
with more coccinelle foo (smpl) than me.

Stephen Hemminger (3):
  bluetooth: 6lowpan dev_close never returns error
  hns: remove useless void cast
  net: make dev_close and related functions void

 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |  2 +-
 include/linux/netdevice.h                        |  4 ++--
 net/bluetooth/6lowpan.c                          |  4 +---
 net/core/dev.c                                   | 26 ++++++++++--------------
 4 files changed, 15 insertions(+), 21 deletions(-)

-- 
2.11.0
