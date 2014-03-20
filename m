From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: bcmgenet: misc fixes
Date: Thu, 20 Mar 2014 10:53:19 -0700
Message-ID: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:53070 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759287AbaCTRxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:53:33 -0400
Received: by mail-pa0-f52.google.com with SMTP id rd3so1273853pab.25
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:53:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains some misc. fixes for the bcmgenet driver.

Thanks!

Florian Fainelli (4):
  net: bcmgenet: remove unused spinlock member
  net: bcmgenet: add skb_tx_timestamp call
  net: bcmgenet: remove bogus tx queue checks
  net: bcmgenet: manipulate netdev_queue directly

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 ++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
 2 files changed, 10 insertions(+), 14 deletions(-)

-- 
1.8.3.2
