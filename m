From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: [PATCH 0/3] Add Hisilicon MDIO bus driver and FEMAC driver
Date: Mon, 13 Jun 2016 14:07:53 +0800
Message-ID: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
To: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch set adds a Hisilicon MDIO bus driver and
a Fast Ethernet MAC(FEMAC) driver.
We found that most ethernet mac drivers use the same ethtool
get_settings and set_settings, so this patch set also adds
common functions for get and set settings.

Dongpo Li (3):
  net: Add MDIO bus driver for the Hisilicon FEMAC
  ethtool: Add common functions for get and set settings
  net: hisilicon: Add Fast Ethernet MAC driver

 .../bindings/net/hisilicon-femac-mdio.txt          |   22 +
 .../devicetree/bindings/net/hisilicon-femac.txt    |   40 +
 drivers/net/ethernet/hisilicon/Kconfig             |   12 +
 drivers/net/ethernet/hisilicon/Makefile            |    1 +
 drivers/net/ethernet/hisilicon/hisi_femac.c        | 1015 ++++++++++++++++++++
 drivers/net/phy/Kconfig                            |    8 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/mdio-hisi-femac.c                  |  165 ++++
 include/linux/ethtool.h                            |    2 +
 net/core/ethtool.c                                 |   21 +
 10 files changed, 1287 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac.txt
 create mode 100644 drivers/net/ethernet/hisilicon/hisi_femac.c
 create mode 100644 drivers/net/phy/mdio-hisi-femac.c

-- 
2.8.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
