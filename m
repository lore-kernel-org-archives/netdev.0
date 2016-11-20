From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 00/18] Update ENA driver to version 1.1.2
Date: Sun, 20 Nov 2016 10:45:29 +0200
Message-ID: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f178.google.com ([209.85.210.178]:33206 "EHLO
        mail-wj0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753242AbcKTIxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:53:12 -0500
Received: by mail-wj0-f178.google.com with SMTP id xy5so14054553wjc.0
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:53:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Amazon's Elastic Network Adapter (ENA) driver version from 1.0.2 to 1.1.2

Netanel Belgazal (18):
  net/ena: remove RFS support from device feature list
  net/ena: fix queues number calculation
  net/ena: use napi_schedule_irqoff when possible
  net/ena: reduce the severity of ena printouts
  net/ena: add hardware hints capability to the driver
  net/ena: fix ethtool RSS flow configuration
  net/ena: refactor ena_get_stats64 to be atomic context safe
  net/ena: change sizeof() argument to be the type pointer
  net/ena: change condition for host attribute configuration
  net/ena: use READ_ONCE to access completion descriptors
  net/ena: fix potential access to freed memory during device reset
  net/ena: refactor skb allocation
  net/ena: remove redundant logic in napi callback for busy poll mode
  net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
  net/ena: remove affinity hint from the driver
  net/ena: fix error handling when probe fails
  net/ena: fix NULL dereference when removing the driver after device
    reset faild
  net/ena: change driver's default timeouts and increase driver version

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  57 +++-
 drivers/net/ethernet/amazon/ena/ena_com.c        |  96 ++++---
 drivers/net/ethernet/amazon/ena/ena_com.h        |   6 +
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   8 +-
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |   1 -
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 326 ++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  30 ++-
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h  |   2 +
 8 files changed, 384 insertions(+), 142 deletions(-)

-- 
1.9.1
