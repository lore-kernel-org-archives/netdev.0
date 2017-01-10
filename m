From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/3] sfc: physical port ids
Date: Tue, 10 Jan 2017 16:22:26 +0000
Message-ID: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:48630 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759230AbdAJQWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:22:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series brings our handling of ndo_get_phys_port_id and related
 interfaces into line with the behaviour of other drivers.

Bert Kenward (3):
  sfc: support ndo_get_phys_port_id even when !CONFIG_SFC_SRIOV
  sfc: implement ndo_get_phys_port_name
  sfc: stop setting dev_port

 drivers/net/ethernet/sfc/ef10.c       | 19 ++++++++++++++++---
 drivers/net/ethernet/sfc/ef10_sriov.c | 14 --------------
 drivers/net/ethernet/sfc/ef10_sriov.h |  3 ---
 drivers/net/ethernet/sfc/efx.c        | 24 +++++++++++++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |  5 +++--
 drivers/net/ethernet/sfc/sriov.c      | 11 -----------
 drivers/net/ethernet/sfc/sriov.h      |  3 ---
 7 files changed, 42 insertions(+), 37 deletions(-)
