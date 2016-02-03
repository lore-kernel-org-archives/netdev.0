From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/4] net: phy: bcm7xxx 40nm PHY fixes
Date: Wed,  3 Feb 2016 13:13:45 -0800
Message-ID: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34863 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699AbcBCVPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:15:50 -0500
Received: by mail-pa0-f48.google.com with SMTP id ho8so19500463pac.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:15:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here is a collection of fixes for the 40nm Ethernet PHY supported
by the 7xxx PHY driver, please also queue these fixes for stable.

Let me know if you think patch 4 is too much of a cleanup to be taken
as a fix.

Thanks!

Florian Fainelli (4):
  net: phy: bcm7xxx: Fix shadow mode 2 disabling
  net: phy: bcm7xxx: Fix 40nm EPHY features
  net: phy: bcm7xxx: Fix bcm7xxx_config_init() check
  net: phy: bcm7xxx: Make MII_BCM7XX_64CLK_MDIO naming consistent

 drivers/net/phy/bcm7xxx.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

-- 
2.1.0
