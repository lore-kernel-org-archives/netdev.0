From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 11:39:41 -0700
Message-ID: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35470 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdH2Spv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:45:51 -0400
Received: by mail-wr0-f195.google.com with SMTP id a47so2842836wra.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:45:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

While trying an ARM BE kernel for kinks, the 3 drivers below started not
working and the reasons why became pretty obvious because the register space
remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
native endian (let's call that a feature).

Thanks!

Florian Fainelli (4):
  net: systemport: Use correct I/O accessors
  net: dsa: bcm_sf2: Use correct I/O accessors
  net: systemport: Set correct RSB endian bits based on host
  net: phy: mdio-bcm-unimac: Use correct I/O accessors

 drivers/net/dsa/bcm_sf2.h                  | 12 +++++------
 drivers/net/ethernet/broadcom/bcmsysport.c | 21 ++++++++++++--------
 drivers/net/phy/mdio-bcm-unimac.c          | 32 ++++++++++++++++++++++++------
 3 files changed, 45 insertions(+), 20 deletions(-)

-- 
1.9.1
