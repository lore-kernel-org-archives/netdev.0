From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 00/13]  Bug Fixes in ENA driver
Date: Thu,  9 Feb 2017 15:21:26 +0200
Message-ID: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37843 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdBIN2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:28:24 -0500
Received: by mail-wm0-f51.google.com with SMTP id v77so19038104wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:28:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from V3:
* Rebase patchset to master and solve merge conflicts.
* Remove redundant bug fix (fix error handling when probe fails)

Netanel Belgazal (13):
  net/ena: remove ntuple filter support from device feature list
  net/ena: fix queues number calculation
  net/ena: fix ethtool RSS flow configuration
  net/ena: fix RSS default hash configuration
  net/ena: fix NULL dereference when removing the driver after device
    reset failed
  net/ena: refactor ena_get_stats64 to be atomic context safe
  net/ena: fix potential access to freed memory during device reset
  net/ena: use napi_complete_done() return value
  net/ena: use READ_ONCE to access completion descriptors
  net/ena: reduce the severity of ena printouts
  net/ena: change driver's default timeouts
  net/ena: change condition for host attribute configuration
  net/ena: update driver version to 1.1.2

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  20 ++-
 drivers/net/ethernet/amazon/ena/ena_com.c        |  41 +++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |   1 +
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   8 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 176 ++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |   9 +-
 6 files changed, 172 insertions(+), 83 deletions(-)

-- 
2.7.4
