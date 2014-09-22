From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2 v2] net: bcmgenet: TX reclaim and DMA fixes
Date: Mon, 22 Sep 2014 11:54:41 -0700
Message-ID: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:55590 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383AbaIVSzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:55:03 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so5035719pad.15
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 11:55:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains one fix for an accounting problem while reclaiming
transmitted buffers having fragments, and the second fix is to make sure
that the DMA shutdown is properly controlled.

Florian Fainelli (2):
  net: bcmgenet: fix TX reclaim accounting for fragments
  net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 110 +++++++++++++------------
 1 file changed, 56 insertions(+), 54 deletions(-)

-- 
1.9.1
