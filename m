From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: RX hash configuration
Date: Tue, 17 Jan 2017 11:59:48 +0000
Message-ID: <2b7fcd41-680f-460e-399a-6aa4ce102a04@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:15371 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750989AbdAQMAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 07:00:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves support for getting and setting RX hashing
 configuration on Solarflare adapters through ethtool.

Edward Cree (2):
  sfc: support setting RSS hash key through ethtool API
  sfc: read back RX hash config from the NIC when querying it with
    ethtool -x

 drivers/net/ethernet/sfc/ef10.c       | 84 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/ethtool.c    | 29 +++++++++---
 drivers/net/ethernet/sfc/farch.c      | 16 +++++++
 drivers/net/ethernet/sfc/net_driver.h |  5 ++-
 drivers/net/ethernet/sfc/nic.h        |  1 +
 drivers/net/ethernet/sfc/siena.c      | 27 ++++++++++-
 6 files changed, 146 insertions(+), 16 deletions(-)
