From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 00/10] net: phy: small cleanups and improvements
Date: Tue, 11 Feb 2014 17:27:32 -0800
Message-ID: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60332 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbaBLB2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset contains some small cleanups which have been sent on the
mailing-list before to improve phy_print_status() and make it useful.

The second part of the patch allows PHY drivers to implement their own
aneg_done() callback.

Finally, two new sysfs properties are exposed to help troubleshoot libphy
aware Linux systems.

Thanks!

Florian Fainelli (10):
  net: phy: use network device in phy_print_status
  net: phy: update phy_print_status to show pause settings
  net: phy: display human readable PHY speed settings
  net: phy: add genphy_aneg_done()
  net: phy: allow driver to implement their own aneg_done
  net: phy: fix phy_{clear,config}_interrupt comment typos
  net: phy: re-design phy_modes to be self-contained
  net: phy: expose PHY device interface mode
  net: phy: add "has_fixups" boolean property
  net: phy: expose phydev->has_fixups to sysfs

 Documentation/ABI/testing/sysfs-bus-mdio | 21 ++++++++++++++
 drivers/net/phy/mdio_bus.c               | 20 ++++++++++++++
 drivers/net/phy/phy.c                    | 46 +++++++++++++++++++++++--------
 drivers/net/phy/phy_device.c             | 18 ++++++++++++
 drivers/of/of_net.c                      | 26 ++----------------
 include/linux/phy.h                      | 47 ++++++++++++++++++++++++++++++++
 6 files changed, 142 insertions(+), 36 deletions(-)

-- 
1.8.3.2
