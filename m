From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: couple mdio_module_driver changes
Date: Sun, 22 Jan 2017 21:17:31 -0800
Message-ID: <20170123051733.10316-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34819 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdAWFRl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 00:17:41 -0500
Received: by mail-pg0-f66.google.com with SMTP id 204so12720927pge.2
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 21:17:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Small patch series fixing a comment for mdio_module_driver and
finally utilizing it in b53_mdio.

Thanks!

Florian Fainelli (2):
  net: phy: Fix typo for MDIO module boilerplate comment
  net: dsa: b53: Utilize mdio_module_driver

 drivers/net/dsa/b53/b53_mdio.c | 13 +------------
 include/linux/mdio.h           |  2 +-
 2 files changed, 2 insertions(+), 13 deletions(-)

-- 
2.9.3
