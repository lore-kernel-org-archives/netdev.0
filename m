From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: phy: broadcom: Support for PHY counters
Date: Mon, 28 Nov 2016 13:06:12 -0800
Message-ID: <20161128210614.12621-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34113 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbcK1VGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:06:17 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so6973288pfb.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:06:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for reading the Broadcom PHYs internal counters.

Florian Fainelli (2):
  net: phy: broadcom: Add support code for reading PHY counters
  net: phy: bcm7xxx: Plug in support for reading PHY error counters

 drivers/net/phy/bcm-phy-lib.c | 67 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h |  5 ++++
 drivers/net/phy/bcm7xxx.c     | 34 ++++++++++++++++++++++
 include/linux/brcmphy.h       |  3 ++
 4 files changed, 109 insertions(+)

-- 
2.9.3
