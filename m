From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH net-next 0/5] Initial SFP support patches
Date: Thu, 23 Jun 2016 14:49:36 +0100
Message-ID: <20160623134936.GX1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45598 "EHLO
	pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbcFWNtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 09:49:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please review and merge this initial patch set, which is part of a
larger set previously posted adding SFP support to phy and mvneta.

This initial set are focused on cleaning up and reorganising the
fixed-phy code to allow the core software-phy code to be re-used.

These are based on net-next.

Thanks.

 drivers/net/phy/Kconfig     |   4 +
 drivers/net/phy/Makefile    |   3 +-
 drivers/net/phy/fixed_phy.c | 153 +++++++------------------------------
 drivers/net/phy/swphy.c     | 179 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/swphy.h     |   9 +++
 5 files changed, 222 insertions(+), 126 deletions(-)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
