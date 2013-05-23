From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/3 v3] phy: allow flagging PHY devices as internal
Date: Thu, 23 May 2013 12:11:10 +0100
Message-ID: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	bhutchings@solarflare.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3301 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758538Ab3EWLd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 07:33:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Andy,

This small patch set updates libphy to allow PHY drivers to flag a
specific PHY device as internal, which is then used to accurately
report the transceiver type (internal vs external) in ethtool.

As far as I can tell we only have one in-tree driver for the moment
which is known to be for internal PHYs.

Florian Fainelli (3):
  net: ethtool: disambiguate XCVR_* meaning
  phy: allow drivers to flag a PHY device as internal
  phy: bcm63xx: report Broadcom BCM63xx PHYs as internal

 drivers/net/phy/bcm63xx.c    |  4 ++--
 drivers/net/phy/phy.c        |  3 ++-
 drivers/net/phy/phy_device.c |  3 +++
 include/linux/phy.h          | 12 ++++++++++++
 include/uapi/linux/ethtool.h |  4 ++--
 5 files changed, 21 insertions(+), 5 deletions(-)

-- 
1.8.1.2
