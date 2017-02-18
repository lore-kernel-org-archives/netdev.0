From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: phy: Fix PHY unbind crash
Date: Fri, 17 Feb 2017 16:07:32 -0800
Message-ID: <20170218000734.32590-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36410 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdBRAOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 19:14:37 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so5017811wmd.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 16:14:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This fixes crashes when the PHY driver is no longer bound to the device.

There is still a fair amount of work to be done to get the unbind -> bind
sequent to result in a functional state, but that will be net-next material.

These two problems existed for as long as PHYLIB as been around.

Thanks!

Florian Fainelli (2):
  net: phy: Fix PHY unbind crash
  net: phy: Check phydev->drv

 drivers/net/phy/phy.c        | 26 ++++++++++++++++++++++----
 drivers/net/phy/phy_device.c |  8 +++++---
 include/linux/phy.h          |  3 +++
 3 files changed, 30 insertions(+), 7 deletions(-)

-- 
2.9.3
