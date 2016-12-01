From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/3] sfc: defalconisation fixups
Date: Thu, 1 Dec 2016 16:59:13 +0000
Message-ID: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:63031 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760204AbcLAQ71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:59:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug fix, the Kconfig change, and cleaning up a bit more unused code.

Edward Cree (3):
  sfc: fix debug message format string in efx_farch_handle_rx_not_ok
  sfc: don't select SFC_FALCON
  sfc: remove RESET_TYPE_RX_RECOVERY

 drivers/net/ethernet/sfc/Kconfig | 1 -
 drivers/net/ethernet/sfc/efx.c   | 1 -
 drivers/net/ethernet/sfc/enum.h  | 5 +----
 drivers/net/ethernet/sfc/farch.c | 2 +-
 4 files changed, 2 insertions(+), 7 deletions(-)
