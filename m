From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: phy: broadcom: define pseudo-PHY address
Date: Wed, 10 Jun 2015 18:07:56 -0700
Message-ID: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:36696 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbFKBJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:11 -0400
Received: by qkx62 with SMTP id 62so33582457qkx.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series converts existing in-tree users of the Broadcom pseudo-PHY
address (30) used to configure MDIO-connected switches to share a constant in a
shared header files.

Thanks!

Florian Fainelli (5):
  net: phy: broadcom: include phy.h for brcmphy.h
  net: phy: broadcom: define Broadcom pseudo-PHY address in brcmphy.h
  b44: Utilize BRCM_PSEUDO_PHY_ADDR
  bgmac: Utilize BRCM_PSEUDO_PHY_ADDR
  net: dsa: bcm_sf2: Utilize BRCM_PSEUDO_PHY_ADDR

 drivers/net/dsa/bcm_sf2.c             | 7 ++++---
 drivers/net/ethernet/broadcom/b44.h   | 8 ++++++--
 drivers/net/ethernet/broadcom/bgmac.h | 3 ++-
 include/linux/brcmphy.h               | 7 +++++++
 4 files changed, 19 insertions(+), 6 deletions(-)

-- 
2.1.0
