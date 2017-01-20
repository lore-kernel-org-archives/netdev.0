From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/7] net: dsa: bcm_sf2: Add support for BCM7278
Date: Fri, 20 Jan 2017 12:36:27 -0800
Message-ID: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32914 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753352AbdATUgn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:43 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so7679201pgd.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom BCM7278 integrated switch
which is a successor of the BCM7445 switch. We have a little bit of
register shuffling going on, which is why most of the functional changes
are to deal with that.

Thanks!

Florian Fainelli (7):
  net: dsa: bcm_sf2: Make SF2_IO64_MACRO() utilize 32-bit macro
  net: dsa: bcm_sf2: Prepare for different register layouts
  net: dsa: bcm_sf2: Add support for BCM7278 integrated switch
  net: dsa: bcm_sf2: Move code enabling Broadcom tags
  net: dsa: bcm_sf2: Allow non-IMP ports to have Broadcom tags enabled
  net: phy: bcm7xxx: Add entry for BCM7278
  net: phy: bcm7xxx: Implement EGPHY workaround for 7278

 .../bindings/net/brcm,bcm7445-switch-v4.0.txt      |  10 +-
 drivers/net/dsa/b53/b53_common.c                   |  12 ++
 drivers/net/dsa/b53/b53_priv.h                     |   4 +-
 drivers/net/dsa/bcm_sf2.c                          | 167 ++++++++++++++++-----
 drivers/net/dsa/bcm_sf2.h                          |  41 ++++-
 drivers/net/dsa/bcm_sf2_regs.h                     |  47 +++---
 drivers/net/phy/bcm7xxx.c                          |  36 +++++
 include/linux/brcmphy.h                            |   1 +
 8 files changed, 261 insertions(+), 57 deletions(-)

-- 
2.9.3
