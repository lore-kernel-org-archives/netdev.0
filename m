From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: phy: broadcom: Wirespeed/downshift support
Date: Tue, 22 Nov 2016 11:40:53 -0800
Message-ID: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35035 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933842AbcKVTlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:10 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so2898963pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom Wirespeed, aka downsfhit feature
utilizing the recently added ethtool PHY tunables.

Tested with two Gigabit link partners with a 4-wire cable having only 2 pairs
connected.

Last patch in the series is a fix that was required for testing, which should
make it to -stable, which I can submit separate against net if you prefer David.

Thanks!

Florian Fainelli (5):
  net: phy: broadcom: Move bcm54xx_auxctl_{read,write} to common library
  net: phy: broadcom: Add support code for downshift/Wirespeed
  net: phy: broadcom: Allow enabling or disabling of EEE
  net: phy: bcm7xxx: Add support for downshift/Wirespeed
  net: dsa: bcm_sf2: Ensure we re-negotiate EEE during after link change

 drivers/net/dsa/bcm_sf2.c     |   4 ++
 drivers/net/phy/bcm-cygnus.c  |   2 +-
 drivers/net/phy/bcm-phy-lib.c | 117 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/phy/bcm-phy-lib.h |  10 +++-
 drivers/net/phy/bcm7xxx.c     |  51 +++++++++++++++++-
 drivers/net/phy/broadcom.c    |  15 ------
 include/linux/brcmphy.h       |  10 ++++
 7 files changed, 187 insertions(+), 22 deletions(-)

-- 
2.9.3
