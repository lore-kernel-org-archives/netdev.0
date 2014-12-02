From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: support for new GPHY revision scheme
Date: Tue,  2 Dec 2014 15:28:00 -0800
Message-ID: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:52224 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932722AbaLBX2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 18:28:13 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so8722252pde.26
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 15:28:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches update the GENET GPHY revision logic to account for some
of our newer designs starting with GPHY rev G0.

Thanks!

Florian Fainelli (2):
  net: bcmgenet: add support for new GENET PHY revision scheme
  net: phy: bcm7xxx: add an explicit version check for GPHY rev G0

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++++++++++++++++-
 drivers/net/phy/bcm7xxx.c                      |  2 ++
 2 files changed, 25 insertions(+), 1 deletion(-)

-- 
2.1.0
