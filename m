From: <netanel@amazon.com>
Subject: [PATCH net-next 00/13] update ena ethernet driver to version 1.2.0
Date: Fri, 9 Jun 2017 00:46:37 +0300
Message-ID: <1496958410-4220-11-git-send-email-netanel@amazon.com>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:63954 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdFHVsf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:48:35 -0400
In-Reply-To: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

This patchset contains some new features/improvements that were added
to the ENA driver to increase its robustness and are based on
experience of wide ENA deployment.

Depends on:
[PATCH net-next 0/8] Bug fixes in ena ethernet driver

Netanel Belgazal (13):
  net: ena: change return value for unsupported features unsupported
    return value
  net: ena: add hardware hints capability to the driver
  net: ena: change sizeof() argument to be the type pointer
  net: ena: add reset reason for each device FLR
  net: ena: add support for out of order rx buffers refill
  net: ena: allow the driver to work with small number of msix vectors
  net: ena: use napi_schedule_irqoff when possible
  net: ena: separate skb allocation to dedicated function
  net: ena: adding missing cast in ena_com_mem_addr_set()
  net: ena: add mtu limitation in ena_change_mtu()
  net: ena: update driver's rx drop statistics
  net: ena: change validate_tx_req_id() to be inline function
  net: ena: update ena driver to version 1.2.0

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  31 +++
 drivers/net/ethernet/amazon/ena/ena_com.c        |  83 ++++--
 drivers/net/ethernet/amazon/ena/ena_com.h        |  10 +-
 drivers/net/ethernet/amazon/ena/ena_eth_com.c    |   5 +
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |  11 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 317 +++++++++++++++++------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  31 ++-
 drivers/net/ethernet/amazon/ena/ena_regs_defs.h  |  34 +++
 8 files changed, 407 insertions(+), 115 deletions(-)

-- 
2.7.4
