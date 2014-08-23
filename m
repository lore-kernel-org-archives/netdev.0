From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/7] net: phy: bcm7xxx: APD and EEE support
Date: Fri, 22 Aug 2014 18:55:38 -0700
Message-ID: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:48457 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaHWB4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:14 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so16831162pdj.30
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series enables Auto-power down and EEE for the BCM7xxx integrated
Gigabit PHYs.

I also put a fix for the fixed PHY that would allow clause 45 over clause 22
reads/writes but would return bogus data by using e.g: ethtool --show-eee

Thanks!

Florian Fainelli (7):
  net: phy: broadcom: extract all registers to brcmphy.h
  net: phy: broadcom: move shadow 0x1C register accessors to brcmphy.h
  net: phy: bcm7xxx: enable auto power down
  net: phy: fixed: return an error for Clause 45 over 22 reads
  net: phy: export phy_{read,write}_mmd_indirect
  net: phy: allow phy_init_eee() to work with internal PHYs
  net: phy: bcm7xxx: enable EEE at the PHY level

 drivers/net/phy/bcm7xxx.c  |  58 ++++++++++++++++++++-
 drivers/net/phy/broadcom.c | 122 -------------------------------------------
 drivers/net/phy/fixed.c    |  11 ++++
 drivers/net/phy/phy.c      |  12 +++--
 include/linux/brcmphy.h    | 126 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h        |  27 ++++++++++
 6 files changed, 229 insertions(+), 127 deletions(-)

-- 
1.9.1
