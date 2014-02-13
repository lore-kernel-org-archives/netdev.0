From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 14:53:39 -0800
Message-ID: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51626 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaBMWz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:55:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
controller. This controller is found on the Broadcom BCM7xxx Set Top Box
System-on-a-chips.

Changes since v2:
- dropped the patch that adds an "internal" phy-mode

Florian Fainelli (10):
  net: phy: add MoCA PHY type
  net: phy: update port type for MoCA PHYs
  net: phy: broadcom: extract register definitions
  net: phy: add Broadcom BCM7xxx internal PHY driver
  net: bcmgenet: add driver definitions and private structure
  net: bcmgenet: add main driver file
  net: bcmgenet: add MDIO routines
  net: bcmgenet: hook into the build system
  Documentation: add Device tree bindings for Broadcom GENET
  MAINTAINERS: add entry for the Broadcom GENET driver

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  121 +
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/broadcom/Kconfig              |   10 +
 drivers/net/ethernet/broadcom/Makefile             |    1 +
 drivers/net/ethernet/broadcom/genet/Makefile       |    2 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 2595 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  630 +++++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  470 ++++
 drivers/net/phy/Kconfig                            |    6 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm7xxx.c                          |  343 +++
 drivers/net/phy/broadcom.c                         |   52 -
 drivers/net/phy/phy.c                              |    5 +-
 include/linux/brcmphy.h                            |   60 +
 include/linux/phy.h                                |    3 +
 15 files changed, 4252 insertions(+), 53 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.c
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.h
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
 create mode 100644 drivers/net/phy/bcm7xxx.c

-- 
1.8.3.2
