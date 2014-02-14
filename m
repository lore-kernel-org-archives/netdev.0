From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 16:08:41 -0800
Message-ID: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
controller. This controller is found on the Broadcom BCM7xxx Set Top Box
System-on-a-chips.

Changes since v4:
- add dependency on CONFIG_OF

Changes since v3:
- fixed Kconfig dependency on FIXED_PHY

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
 drivers/net/ethernet/broadcom/Kconfig              |   11 +
 drivers/net/ethernet/broadcom/Makefile             |    1 +
 drivers/net/ethernet/broadcom/genet/Makefile       |    2 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 2595 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  630 +++++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  464 ++++
 drivers/net/phy/Kconfig                            |    6 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm7xxx.c                          |  343 +++
 drivers/net/phy/broadcom.c                         |   52 -
 drivers/net/phy/phy.c                              |    5 +-
 include/linux/brcmphy.h                            |   60 +
 include/linux/phy.h                                |    3 +
 15 files changed, 4247 insertions(+), 53 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.c
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.h
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
 create mode 100644 drivers/net/phy/bcm7xxx.c

-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
