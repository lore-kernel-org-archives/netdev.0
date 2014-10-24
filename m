From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: bcmgenet: switch to TX NAPI
Date: Fri, 24 Oct 2014 13:02:18 -0700
Message-ID: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48526 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaJXUCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 16:02:50 -0400
Received: by mail-pa0-f46.google.com with SMTP id lf10so82391pab.19
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 13:02:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Petri,

This patch set updates the GENET driver to switch the transmit to NAPI instead
of using a mix of hard interrupt + RX NAPI reclaim.

Florian Fainelli (4):
  net: bcmgenet: consistently use UMAC_IRQ_RXDMA_MASK
  net: bcmgenet: return number of packets completed in TX reclaim
  net: bcmgenet: reclaim transmitted buffers in NAPI context
  net: bcmgenet: update ring producer index and buffer count in xmit

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 71 ++++++++++++--------------
 1 file changed, 32 insertions(+), 39 deletions(-)

-- 
1.9.1
