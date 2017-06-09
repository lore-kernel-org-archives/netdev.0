From: <netanel@amazon.com>
Subject: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Sat, 10 Jun 2017 01:13:49 +0300
Message-ID: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:19314 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbdFIWOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 18:14:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

This patchset contains fixes for the bugs that were discovered so far.

Netanel Belgazal (8):
  net: ena: fix rare uncompleted admin command false alarm
  net: ena: fix bug that might cause hang after consecutive open/close
    interface.
  net: ena: add missing return when ena_com_get_io_handlers() fails
  net: ena: fix race condition between submit and completion admin
    command
  net: ena: add missing unmap bars on device removal
  net: ena: fix theoretical Rx hang on low memory systems
  net: ena: disable admin msix while working in polling mode
  net: ena: bug fix in lost tx packets detection mechanism

 drivers/net/ethernet/amazon/ena/ena_com.c     |  35 +++--
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |   2 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 179 +++++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h  |  16 ++-
 4 files changed, 168 insertions(+), 64 deletions(-)

-- 
2.7.4
