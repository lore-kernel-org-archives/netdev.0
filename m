From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/2] net: phy: broadcom: Support for PHY counters
Date: Tue, 29 Nov 2016 09:57:16 -0800
Message-ID: <20161129175718.20213-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35029 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753695AbcK2R5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:57:25 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so17045870pga.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:57:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for reading the Broadcom PHYs internal counters.

Changes in v3:

- fixed the allocation of priv->stats in bcm7xxx

Changes in v2:

- fixed modular build reported by kbuild

- constify array of stats

Florian Fainelli (2):
  net: phy: broadcom: Add support code for reading PHY counters
  net: phy: bcm7xxx: Plug in support for reading PHY error counters

 drivers/net/phy/bcm-phy-lib.c | 70 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h |  5 ++++
 drivers/net/phy/bcm7xxx.c     | 35 ++++++++++++++++++++++
 include/linux/brcmphy.h       |  3 ++
 4 files changed, 113 insertions(+)

-- 
2.9.3
