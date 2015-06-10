From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] net: broadcom MDIO support for broken turn-around
Date: Wed, 10 Jun 2015 12:24:09 -0700
Message-ID: <1433964251-17338-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33772 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933726AbbFJTZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 15:25:16 -0400
Received: by qgfa66 with SMTP id a66so19782978qgf.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 12:25:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches update the GENET and UniMAC MDIO controllers to deal with
PHYs that are known to have a broken turn-around bug (e.g: BCM53125 and others)

This utilizes the infrastructure that code recently added to do that in 'net-next'.

Note that the changes look nearly identical and I will try to address the MDIO
code duplication between GENET and UniMAC in a future patch series.

Thanks!

Changes in v2:
- remove brcmphy.h include in mdio-bcm-unimac.c
- use the same comment as with GENET's MDIO read function

Florian Fainelli (2):
  net: bcmgenet: handle broken turn-around for specific PHYs
  net: phy: mdio-bcm-unimac: handle broken turn-around for specific PHYs

 drivers/net/ethernet/broadcom/genet/bcmmii.c | 7 ++++++-
 drivers/net/phy/mdio-bcm-unimac.c            | 8 +++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

-- 
2.1.0
