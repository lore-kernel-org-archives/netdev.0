From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] net: bcmgenet: support for new GPHY revision scheme
Date: Wed,  3 Dec 2014 09:56:58 -0800
Message-ID: <1417629420-31146-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:54802 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbaLCR5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:57:12 -0500
Received: by mail-pd0-f182.google.com with SMTP id r10so15981324pdi.27
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:57:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches update the GENET GPHY revision logic to account for some
of our newer designs starting with GPHY rev G0.

Florian Fainelli (2):
  net: bcmgenet: add support for new GENET PHY revision scheme
  net: phy: bcm7xxx: add an explicit version check for GPHY rev G0

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++++++++++++++++-
 drivers/net/phy/bcm7xxx.c                      |  2 ++
 2 files changed, 25 insertions(+), 1 deletion(-)

-- 
2.1.0
