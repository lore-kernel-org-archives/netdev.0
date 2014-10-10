From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/3] net: bcmgenet & systemport fixes
Date: Fri, 10 Oct 2014 10:51:51 -0700
Message-ID: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62533 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaJJRwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:52:07 -0400
Received: by mail-pd0-f170.google.com with SMTP id p10so2083532pdj.29
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 10:52:06 -0700 (PDT)
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
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 9 ++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 4 +++-
 3 files changed, 9 insertions(+), 7 deletions(-)

-- 
1.9.1
