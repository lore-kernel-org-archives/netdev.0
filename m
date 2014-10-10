From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: bcmgenet & systemport fixes
Date: Thu,  9 Oct 2014 18:06:34 -0700
Message-ID: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52668 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJJBGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:06:53 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so719212pad.1
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:06:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes an off-by-one error introduced during a previous
change, and the two other fixes fix a wake depth imbalance situation for
the Wake-on-LAN interrupt line.

Thanks!

Florian Fainelli (3):
  net: bcmgenet: fix off-by-one in incrementing read pointer
  net: bcmgenet: avoid unbalanced enable_irq_wake calls
  net: systemport: avoid unbalanced enable_irq_wake calls

 drivers/net/ethernet/broadcom/bcmsysport.c         | 3 ++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 6 +++---
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 4 +++-
 3 files changed, 8 insertions(+), 5 deletions(-)

-- 
1.9.1
