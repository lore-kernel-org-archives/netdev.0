From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: phy: bcm7xxx: Misc cleanups
Date: Sat,  6 Feb 2016 13:09:35 -0800
Message-ID: <1454792977-7987-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34589 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbcBFVJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 16:09:42 -0500
Received: by mail-pf0-f173.google.com with SMTP id o185so87872546pfb.1
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 13:09:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches are cleanups to the BCM7xxx internal PHY driver:

- fix a constant name missing a X (as in BCM7XXX)
- add a macro to reduce the amount of code duplication to add new entries

Thanks!

Florian Fainelli (2):
  net: phy: bcm7xxx: Make MII_BCM7XX_64CLK_MDIO naming consistent
  net: phy: bcm7xxx: Reduce boilerplate code for 40nm EPHY

 drivers/net/phy/bcm7xxx.c |   58 +++++++++++++++-----------------------------
 1 files changed, 20 insertions(+), 38 deletions(-)
