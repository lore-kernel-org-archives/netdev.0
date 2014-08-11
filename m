From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/4] net: bcmgenet: Wake-on-LAN and suspend fixes
Date: Mon, 11 Aug 2014 14:50:41 -0700
Message-ID: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:39802 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaHKVvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:51:05 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so11860339pad.10
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 14:51:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes some mistakes that were introduced during the driver
changes adding support suspend/resume and Wake-on-LAN.

Thanks!

Florian Fainelli (4):
  net: bcmgenet: request and enable main clock earlier
  net: bcmgenet: correctly suspend and resume PHY device
  net: bcmgenet: update UMAC_CMD only when link is detected
  net: bcmgenet: correctly resume adapter from Wake-on-LAN

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 37 +++++++++++++++++---------
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  8 ++++--
 2 files changed, 30 insertions(+), 15 deletions(-)

-- 
1.9.1
