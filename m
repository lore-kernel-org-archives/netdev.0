From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Bug fixes.
Date: Thu, 28 Jan 2016 03:11:19 -0500
Message-ID: <1453968682-10014-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:34673 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934754AbcA1ILX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 03:11:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 small bug fix patches for net.

Michael Chan (3):
  bnxt_en: Ring free response from close path should use completion ring
  bnxt_en: Exclude rx_drop_pkts hw counter from the stack's rx_dropped
    counter.
  bnxt_en: Fix crash in bnxt_free_tx_skbs() during tx timeout.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

-- 
1.8.3.1
