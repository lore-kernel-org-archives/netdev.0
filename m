From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 00/10] Support for Broadcom GENET driver
Date: Tue, 11 Feb 2014 20:07:23 -0800
Message-ID: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:5879 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaBLEIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:08:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
controller. This controller is found on the Broadcom BCM7xxx Set Top Box
System-on-a-Chip.

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
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 2685 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  631 +++++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  483 ++++
 drivers/net/phy/Kconfig                            |    6 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm7xxx.c                          |  322 +++
 drivers/net/phy/phy.c                              |    5 +-
 drivers/of/of_net.c                                |    2 +
 include/linux/brcmphy.h                            |    9 +
 include/linux/phy.h                                |    5 +-
 15 files changed, 4277 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.c
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.h
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
 create mode 100644 drivers/net/phy/bcm7xxx.c

-- 
1.8.3.2
