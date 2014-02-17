From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: phy: soft reset rework for 10G PHYs
Date: Mon, 17 Feb 2014 12:52:43 -0800
Message-ID: <1392670366-31457-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:7655 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbaBQUxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

As reported by Shaohui, 10G PHYs may have a slightly more complex reset
sequence for which a BMCR_RESET software reset might not suffice. This
patchset offers a solution for those by allowing them to implement their
own soft_reset() callback. Finally there is an update to the PHY library
Documentation to cover for the newly added callbacks of the PHY driver
structure.

Thanks!

Florian Fainelli (3):
  net: phy: move PHY software reset to genphy_soft_reset
  net: phy: allow PHY drivers to implement their own software reset
  Documentation: networking: update phy.txt with recent changes

 Documentation/networking/phy.txt |  9 +++++++++
 drivers/net/phy/phy_device.c     | 39 ++++++++++++++++++++++++++++++++++-----
 include/linux/phy.h              |  6 ++++++
 3 files changed, 49 insertions(+), 5 deletions(-)

-- 
1.8.3.2
