From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 00/10] Support for the Broadcom GENET driver
Date: Wed, 12 Feb 2014 21:29:45 -0800
Message-ID: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:8684 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbaBMFa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 00:30:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset adds support for the Broadcom GENET Gigabita Ethernet MAC
controllers version 1 to v4. This controller is found on the Broadcom
BCM7xxx Set Top Box System-on-a-Chip hardware.

Florian Fainelli (10):
  net: phy: add "internal" PHY mode
  net: phy: add MoCA PHY type
  net: phy: update port type for MoCA PHYs
  net: phy: add Broadcom BCM7xxx internal PHY driver
  net: bcmgenet: add driver definitions and private structure
  net: bcmgenet: add main driver file
  net: bcmgenet: add MDIO routines
  net: bcmgenet: hook into the build system
  Documentation: add Device tree bindings for Broadcom GENET
  MAINTAINERS: add entry for the Broadcom GENET driver

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  111 +
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/broadcom/Kconfig              |   10 +
 drivers/net/ethernet/broadcom/Makefile             |    1 +
 drivers/net/ethernet/broadcom/genet/Makefile       |    2 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 2664 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  624 +++++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  481 ++++
 drivers/net/phy/Kconfig                            |    6 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm7xxx.c                          |  322 +++
 drivers/net/phy/phy.c                              |    5 +-
 include/linux/brcmphy.h                            |    9 +
 include/linux/phy.h                                |    9 +-
 14 files changed, 4249 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.c
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.h
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
 create mode 100644 drivers/net/phy/bcm7xxx.c

-- 
1.8.3.2
