From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: bcmgenet: TX reclaim and DMA fixes
Date: Thu, 18 Sep 2014 17:48:15 -0700
Message-ID: <1411087697-19306-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:60138 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaISAsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:48:32 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so2689017pad.31
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:48:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains one fix for an accounting problem while reclaiming
transmitted buffers having fragments, and the second fix is to make sure
that the DMA shutdown is properly controlled.

Florian Fainelli (2):
  net: bcmgenet: fix TX reclaim accounting for fragments
  net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

-- 
1.9.1
