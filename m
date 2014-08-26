From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] Broadcom BCM7xxx PHY updates for new entries
Date: Tue, 26 Aug 2014 13:05:06 -0700
Message-ID: <1409083510-29511-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46090 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbaHZUFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:05:43 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so23209878pde.32
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 13:05:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Another week, another set of updates for the Broadcom BCM7xxx PHY driver.  This
patch set cleanups the existing definitions, adds a macro to ease the addition
of future chips, and finally add two new SoCs to the list of supported chips.

Thanks!

Florian Fainelli (4):
  net: phy: bcm7xxx: introduce BCM7XXX_28NM_GPHY macro
  net: phy: broadcom: fix PHY_BCM_OUI_4
  net: phy: broadcom: add new Broadcom OUI
  net: phy: bcm7xxx: add BCM7250 and BCM7364 PHY entries

 drivers/net/phy/bcm7xxx.c | 58 ++++++++++++++++++-----------------------------
 include/linux/brcmphy.h   |  6 +++--
 2 files changed, 26 insertions(+), 38 deletions(-)

-- 
1.9.1
