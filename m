From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport & bcmgenet instrumenting
Date: Wed, 19 Nov 2014 10:29:54 -0800
Message-ID: <1416421796-27657-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:59828 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327AbaKSSaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:30:09 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1336823pdb.28
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:30:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches add similar instrumenting in the driver by logging RX SKB
allocation failures as well as RX & TX DMA mapping failures in order to help
troubleshoot heavy memory pressure conditions.

Thanks!

Florian Fainelli (2):
  net: systemport: log RX buffer allocation and RX/TX DMA failures
  net: bcmgenet: log RX buffer allocation and RX/TX dma failures

 drivers/net/ethernet/broadcom/bcmsysport.c     | 10 +++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h     |  3 +++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 +++++++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  3 +++
 4 files changed, 24 insertions(+), 2 deletions(-)

-- 
1.9.1
