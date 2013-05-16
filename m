From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/2 net-next] phy: PHY_IGNORE_INTERRUPT fixes and
 improvements
Date: Thu, 16 May 2013 18:04:54 +0000
Message-ID: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4953 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab3EPSFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 14:05:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Andy,

These two patches contain fixes and improvements for using PHY_IGNORE_INTERRUPT
in network drivers. Since the second patch is an addition and not a bug fix
per-se, these patches are based on net-net. The first patch applies cleanly
to "net" too.

Thanks!

Florian Fainelli (2):
  phy: fix the use of PHY_IGNORE_INTERRUPT
  phy: add phy_mac_interrupt() to use with PHY_IGNORE_INTERRUPT

 drivers/net/phy/phy.c        | 20 ++++++++++++--------
 drivers/net/phy/phy_device.c |  6 ++++--
 include/linux/phy.h          |  2 ++
 3 files changed, 18 insertions(+), 10 deletions(-)

-- 
1.8.1.2
