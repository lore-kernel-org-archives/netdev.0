From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: TX PIO fixes
Date: Fri, 13 Jan 2017 21:18:38 +0000
Message-ID: <eae20bb1-89d4-0e81-6c56-0c7058d06ada@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:26530 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751084AbdAMVTK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 16:19:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Edward Cree (2):
  sfc: allow PIO more often
  sfc: get PIO buffer size from the NIC

 drivers/net/ethernet/sfc/ef10.c       | 21 +++++++++++++++------
 drivers/net/ethernet/sfc/net_driver.h |  9 +++++++++
 drivers/net/ethernet/sfc/nic.h        | 19 ++++++++++++++++---
 drivers/net/ethernet/sfc/siena.c      |  1 +
 drivers/net/ethernet/sfc/tx.c         |  2 +-
 5 files changed, 42 insertions(+), 10 deletions(-)
