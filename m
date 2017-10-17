From: <netanel@amazon.com>
Subject: [PATCH net-next 0/6] update ENA driver to releawse 1.3.0
Date: Tue, 17 Oct 2017 07:33:55 +0000
Message-ID: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:4942 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933027AbdJQHea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Netanel Belgazal (6):
  net: ena: improve ENA driver boot time.
  net: ena: remove legacy suspend suspend/resume support
  net: ena: add power management ops to the ENA driver
  net: ena: add statistics for missed tx packets
  net: ena: add new admin define for future support of IPv6 RSS
  net: ena: increase ena driver version to 1.3.0

 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |   6 +
 drivers/net/ethernet/amazon/ena/ena_com.c        |  12 +-
 drivers/net/ethernet/amazon/ena/ena_ethtool.c    |   5 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 197 ++++++++++++-----------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  12 +-
 5 files changed, 130 insertions(+), 102 deletions(-)

-- 
1.8.3.1
