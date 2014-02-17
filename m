From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3] net: phy: soft reset rework for 10G PHYs
Date: Mon, 17 Feb 2014 13:34:01 -0800
Message-ID: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:44959 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbaBQVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:34:32 -0500
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

Changes in v2:
- fixed callback testing
- fixed typo in Documentation

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
