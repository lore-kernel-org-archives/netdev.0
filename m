From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/2 net-next] phy: allow flagging a device as internal
Date: Tue, 21 May 2013 11:37:04 +0100
Message-ID: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2296 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab3EUKqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 06:46:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Andy,

This small patch set updates libphy to allow PHY drivers to flag a
specific PHY device as internal, which is then used to accurately
report the transceiver type (internal vs external) in ethtool.

As far as I can tell we only have one in-tree driver for the moment
which is known to be for internal PHYs.

Florian Fainelli (2):
  phy: allow drivers to flag a PHY device as internal
  phy: bcm63xx: report Broadcom BCM63xx PHYs as internal

 drivers/net/phy/bcm63xx.c    | 4 ++--
 drivers/net/phy/phy.c        | 2 +-
 drivers/net/phy/phy_device.c | 3 +++
 include/linux/phy.h          | 3 +++
 4 files changed, 9 insertions(+), 3 deletions(-)

-- 
1.8.1.2
