From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] make of_set_phy_supported work with genphy driver
Date: Wed, 21 May 2014 15:29:43 +0200
Message-ID: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49075 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaEUN3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 09:29:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio phys recently gained support for specifying the phy speed
via devicetree. This currently only works with the hardware specific
phy drivers but not with the genphy driver. This series fixes this.

Sascha

----------------------------------------------------------------
Sascha Hauer (2):
      net: phy: genphy: Allow overwriting features
      net: phy: make of_set_phy_supported work with genphy driver

 drivers/net/phy/phy_device.c | 47 +++++++++++++++++++++++++++++++++++++-------
 drivers/of/of_mdio.c         | 26 ------------------------
 2 files changed, 40 insertions(+), 33 deletions(-)
