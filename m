From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/4] net: phy: bcm7xxx 40nm PHY fixes
Date: Sat,  6 Feb 2016 12:58:47 -0800
Message-ID: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33393 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcBFU6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:58:55 -0500
Received: by mail-pf0-f178.google.com with SMTP id w123so88100411pfb.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:58:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian.fainelli@broadcom.com>

Hi David,

Here is a collection of fixes for the 40nm Ethernet PHY supported
by the 7xxx PHY driver, please also queue these fixes for stable.

Changes in v2:

- dropped the cleanup patch, not appropriate
- added another patch removing bogus wildcard entries

Thanks!

Florian Fainelli (4):
  net: phy: bcm7xxx: Fix shadow mode 2 disabling
  net: phy: bcm7xxx: Fix 40nm EPHY features
  net: phy: bcm7xxx: Fix bcm7xxx_config_init() check
  net: phy: bcm7xxx: Remove wildcard entries

 drivers/net/phy/bcm7xxx.c |   43 ++++---------------------------------------
 1 files changed, 4 insertions(+), 39 deletions(-)
