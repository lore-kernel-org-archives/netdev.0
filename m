From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/2 net-next v2] phy: PHY_IGNORE_INTERRUPT fixes and
 improvements
Date: Mon, 20 May 2013 08:53:41 +0000
Message-ID: <1369040023-22270-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1999 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139Ab3ETIyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 04:54:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Andy,

These two patches contain fixes and improvements for using PHY_IGNORE_INTERRUPT
in network drivers. Since the second patch is an addition and not a bug fix
per-se, these patches are based on "net-next". The first patch applies cleanly
to "net" too.

Florian Fainelli (2):
  phy: fix the use of PHY_IGNORE_INTERRUPT
  phy: add phy_mac_interrupt() to use with PHY_IGNORE_INTERRUPT

 drivers/net/phy/phy.c        | 23 ++++++++++++++---------
 drivers/net/phy/phy_device.c |  8 ++++++--
 include/linux/phy.h          | 14 ++++++++++++++
 3 files changed, 34 insertions(+), 11 deletions(-)

-- 
1.8.1.2
