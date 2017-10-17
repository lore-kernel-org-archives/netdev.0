From: <netanel@amazon.com>
Subject: [PATCH net 0/3] ENA ethernet driver bug fixes
Date: Tue, 17 Oct 2017 07:33:02 +0000
Message-ID: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:22684 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbdJQHdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Some fixes for ENA ethernet driver

Netanel Belgazal (3):
  net: ena: reduce the severity of some printouts
  net: ena: fix rare kernel crash when bar memory remap fails
  net: ena: fix wrong max Tx/Rx queues on ethtool

 drivers/net/ethernet/amazon/ena/ena_ethtool.c | 4 ++--
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 7 ++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

-- 
1.8.3.1
