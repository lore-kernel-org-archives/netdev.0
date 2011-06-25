From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 12/72] sfc: Move the Solarflare drivers
Date: Sat, 25 Jun 2011 06:58:23 -0700
Message-ID: <1309010363-22750-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab1FYN77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:59 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Solarflare drivers into drivers/net/ethernet/sfc/ and
make the necessary Kconfig and Makefile changes.

CC: Steve Hodgson <shodgson@solarflare.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                    |    2 +-
 drivers/net/Kconfig                            |    2 --
 drivers/net/Makefile                           |    1 -
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/{ => ethernet}/sfc/Kconfig         |    0
 drivers/net/{ => ethernet}/sfc/Makefile        |    0
 drivers/net/{ => ethernet}/sfc/bitfield.h      |    0
 drivers/net/{ => ethernet}/sfc/efx.c           |    0
 drivers/net/{ => ethernet}/sfc/efx.h           |    0
 drivers/net/{ => ethernet}/sfc/enum.h          |    0
 drivers/net/{ => ethernet}/sfc/ethtool.c       |    0
 drivers/net/{ => ethernet}/sfc/falcon.c        |    0
 drivers/net/{ => ethernet}/sfc/falcon_boards.c |    0
 drivers/net/{ => ethernet}/sfc/falcon_xmac.c   |    0
 drivers/net/{ => ethernet}/sfc/filter.c        |    0
 drivers/net/{ => ethernet}/sfc/filter.h        |    0
 drivers/net/{ => ethernet}/sfc/io.h            |    0
 drivers/net/{ => ethernet}/sfc/mac.h           |    0
 drivers/net/{ => ethernet}/sfc/mcdi.c          |    0
 drivers/net/{ => ethernet}/sfc/mcdi.h          |    0
 drivers/net/{ => ethernet}/sfc/mcdi_mac.c      |    0
 drivers/net/{ => ethernet}/sfc/mcdi_pcol.h     |    0
 drivers/net/{ => ethernet}/sfc/mcdi_phy.c      |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.c      |    0
 drivers/net/{ => ethernet}/sfc/mdio_10g.h      |    0
 drivers/net/{ => ethernet}/sfc/mtd.c           |    0
 drivers/net/{ => ethernet}/sfc/net_driver.h    |    0
 drivers/net/{ => ethernet}/sfc/nic.c           |    0
 drivers/net/{ => ethernet}/sfc/nic.h           |    0
 drivers/net/{ => ethernet}/sfc/phy.h           |    0
 drivers/net/{ => ethernet}/sfc/qt202x_phy.c    |    0
 drivers/net/{ => ethernet}/sfc/regs.h          |    0
 drivers/net/{ => ethernet}/sfc/rx.c            |    0
 drivers/net/{ => ethernet}/sfc/selftest.c      |    0
 drivers/net/{ => ethernet}/sfc/selftest.h      |    0
 drivers/net/{ => ethernet}/sfc/siena.c         |    0
 drivers/net/{ => ethernet}/sfc/spi.h           |    0
 drivers/net/{ => ethernet}/sfc/tenxpress.c     |    0
 drivers/net/{ => ethernet}/sfc/tx.c            |    0
 drivers/net/{ => ethernet}/sfc/txc43128_phy.c  |    0
 drivers/net/{ => ethernet}/sfc/workarounds.h   |    0
 42 files changed, 3 insertions(+), 4 deletions(-)
 rename drivers/net/{ => ethernet}/sfc/Kconfig (100%)
 rename drivers/net/{ => ethernet}/sfc/Makefile (100%)
 rename drivers/net/{ => ethernet}/sfc/bitfield.h (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/efx.h (100%)
 rename drivers/net/{ => ethernet}/sfc/enum.h (100%)
 rename drivers/net/{ => ethernet}/sfc/ethtool.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_boards.c (100%)
 rename drivers/net/{ => ethernet}/sfc/falcon_xmac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.c (100%)
 rename drivers/net/{ => ethernet}/sfc/filter.h (100%)
 rename drivers/net/{ => ethernet}/sfc/io.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mac.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_mac.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_pcol.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mcdi_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.c (100%)
 rename drivers/net/{ => ethernet}/sfc/mdio_10g.h (100%)
 rename drivers/net/{ => ethernet}/sfc/mtd.c (100%)
 rename drivers/net/{ => ethernet}/sfc/net_driver.h (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.c (100%)
 rename drivers/net/{ => ethernet}/sfc/nic.h (100%)
 rename drivers/net/{ => ethernet}/sfc/phy.h (100%)
 rename drivers/net/{ => ethernet}/sfc/qt202x_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/regs.h (100%)
 rename drivers/net/{ => ethernet}/sfc/rx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.c (100%)
 rename drivers/net/{ => ethernet}/sfc/selftest.h (100%)
 rename drivers/net/{ => ethernet}/sfc/siena.c (100%)
 rename drivers/net/{ => ethernet}/sfc/spi.h (100%)
 rename drivers/net/{ => ethernet}/sfc/tenxpress.c (100%)
 rename drivers/net/{ => ethernet}/sfc/tx.c (100%)
 rename drivers/net/{ => ethernet}/sfc/txc43128_phy.c (100%)
 rename drivers/net/{ => ethernet}/sfc/workarounds.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index cc9c060..cc16a52f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5663,7 +5663,7 @@ M:	Steve Hodgson <shodgson@solarflare.com>
 M:	Ben Hutchings <bhutchings@solarflare.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/sfc/
+F:	drivers/net/ethernet/sfc/
 
 SGI GRU DRIVER
 M:	Jack Steiner <steiner@sgi.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7ac2b56..51dbdb5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1781,8 +1781,6 @@ config BNA
 
 	  <http://support.brocade.com>
 
-source "drivers/net/sfc/Kconfig"
-
 source "drivers/net/benet/Kconfig"
 
 endif # NETDEV_10000
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 60880d2..b616154 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -219,7 +219,6 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
 obj-$(CONFIG_FS_ENET) += fs_enet/
 
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
-obj-$(CONFIG_SFC) += sfc/
 
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 82d7438..37819a1 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
+source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a3ce80c..917131c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,5 +10,6 @@ obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
+obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
diff --git a/drivers/net/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
similarity index 100%
rename from drivers/net/sfc/Kconfig
rename to drivers/net/ethernet/sfc/Kconfig
diff --git a/drivers/net/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
similarity index 100%
rename from drivers/net/sfc/Makefile
rename to drivers/net/ethernet/sfc/Makefile
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
similarity index 100%
rename from drivers/net/sfc/bitfield.h
rename to drivers/net/ethernet/sfc/bitfield.h
diff --git a/drivers/net/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
similarity index 100%
rename from drivers/net/sfc/efx.c
rename to drivers/net/ethernet/sfc/efx.c
diff --git a/drivers/net/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
similarity index 100%
rename from drivers/net/sfc/efx.h
rename to drivers/net/ethernet/sfc/efx.h
diff --git a/drivers/net/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
similarity index 100%
rename from drivers/net/sfc/enum.h
rename to drivers/net/ethernet/sfc/enum.h
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
similarity index 100%
rename from drivers/net/sfc/ethtool.c
rename to drivers/net/ethernet/sfc/ethtool.c
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
similarity index 100%
rename from drivers/net/sfc/falcon.c
rename to drivers/net/ethernet/sfc/falcon.c
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
similarity index 100%
rename from drivers/net/sfc/falcon_boards.c
rename to drivers/net/ethernet/sfc/falcon_boards.c
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/ethernet/sfc/falcon_xmac.c
similarity index 100%
rename from drivers/net/sfc/falcon_xmac.c
rename to drivers/net/ethernet/sfc/falcon_xmac.c
diff --git a/drivers/net/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
similarity index 100%
rename from drivers/net/sfc/filter.c
rename to drivers/net/ethernet/sfc/filter.c
diff --git a/drivers/net/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
similarity index 100%
rename from drivers/net/sfc/filter.h
rename to drivers/net/ethernet/sfc/filter.h
diff --git a/drivers/net/sfc/io.h b/drivers/net/ethernet/sfc/io.h
similarity index 100%
rename from drivers/net/sfc/io.h
rename to drivers/net/ethernet/sfc/io.h
diff --git a/drivers/net/sfc/mac.h b/drivers/net/ethernet/sfc/mac.h
similarity index 100%
rename from drivers/net/sfc/mac.h
rename to drivers/net/ethernet/sfc/mac.h
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
similarity index 100%
rename from drivers/net/sfc/mcdi.c
rename to drivers/net/ethernet/sfc/mcdi.c
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
similarity index 100%
rename from drivers/net/sfc/mcdi.h
rename to drivers/net/ethernet/sfc/mcdi.h
diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
similarity index 100%
rename from drivers/net/sfc/mcdi_mac.c
rename to drivers/net/ethernet/sfc/mcdi_mac.c
diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
similarity index 100%
rename from drivers/net/sfc/mcdi_pcol.h
rename to drivers/net/ethernet/sfc/mcdi_pcol.h
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/ethernet/sfc/mcdi_phy.c
similarity index 100%
rename from drivers/net/sfc/mcdi_phy.c
rename to drivers/net/ethernet/sfc/mcdi_phy.c
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/ethernet/sfc/mdio_10g.c
similarity index 100%
rename from drivers/net/sfc/mdio_10g.c
rename to drivers/net/ethernet/sfc/mdio_10g.c
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/ethernet/sfc/mdio_10g.h
similarity index 100%
rename from drivers/net/sfc/mdio_10g.h
rename to drivers/net/ethernet/sfc/mdio_10g.h
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
similarity index 100%
rename from drivers/net/sfc/mtd.c
rename to drivers/net/ethernet/sfc/mtd.c
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
similarity index 100%
rename from drivers/net/sfc/net_driver.h
rename to drivers/net/ethernet/sfc/net_driver.h
diff --git a/drivers/net/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
similarity index 100%
rename from drivers/net/sfc/nic.c
rename to drivers/net/ethernet/sfc/nic.c
diff --git a/drivers/net/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
similarity index 100%
rename from drivers/net/sfc/nic.h
rename to drivers/net/ethernet/sfc/nic.h
diff --git a/drivers/net/sfc/phy.h b/drivers/net/ethernet/sfc/phy.h
similarity index 100%
rename from drivers/net/sfc/phy.h
rename to drivers/net/ethernet/sfc/phy.h
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/ethernet/sfc/qt202x_phy.c
similarity index 100%
rename from drivers/net/sfc/qt202x_phy.c
rename to drivers/net/ethernet/sfc/qt202x_phy.c
diff --git a/drivers/net/sfc/regs.h b/drivers/net/ethernet/sfc/regs.h
similarity index 100%
rename from drivers/net/sfc/regs.h
rename to drivers/net/ethernet/sfc/regs.h
diff --git a/drivers/net/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
similarity index 100%
rename from drivers/net/sfc/rx.c
rename to drivers/net/ethernet/sfc/rx.c
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
similarity index 100%
rename from drivers/net/sfc/selftest.c
rename to drivers/net/ethernet/sfc/selftest.c
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
similarity index 100%
rename from drivers/net/sfc/selftest.h
rename to drivers/net/ethernet/sfc/selftest.h
diff --git a/drivers/net/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
similarity index 100%
rename from drivers/net/sfc/siena.c
rename to drivers/net/ethernet/sfc/siena.c
diff --git a/drivers/net/sfc/spi.h b/drivers/net/ethernet/sfc/spi.h
similarity index 100%
rename from drivers/net/sfc/spi.h
rename to drivers/net/ethernet/sfc/spi.h
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/ethernet/sfc/tenxpress.c
similarity index 100%
rename from drivers/net/sfc/tenxpress.c
rename to drivers/net/ethernet/sfc/tenxpress.c
diff --git a/drivers/net/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
similarity index 100%
rename from drivers/net/sfc/tx.c
rename to drivers/net/ethernet/sfc/tx.c
diff --git a/drivers/net/sfc/txc43128_phy.c b/drivers/net/ethernet/sfc/txc43128_phy.c
similarity index 100%
rename from drivers/net/sfc/txc43128_phy.c
rename to drivers/net/ethernet/sfc/txc43128_phy.c
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
similarity index 100%
rename from drivers/net/sfc/workarounds.h
rename to drivers/net/ethernet/sfc/workarounds.h
-- 
1.7.5.4

