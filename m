From: ddaney.cavm@gmail.com
Subject: [PATCH 1/3] MIPS: Octeon: Move some Ethernet support files out of staging.
Date: Thu, 10 Nov 2011 16:29:45 -0800
Message-ID: <1320971387-29343-2-git-send-email-ddaney.cavm@gmail.com>
References: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de, devel@driverdev.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59777 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284Ab1KKA3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 19:29:55 -0500
Received: by ywf7 with SMTP id 7so3642658ywf.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 16:29:54 -0800 (PST)
In-Reply-To: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/cavium-octeon/executive/Makefile         |    5 +
 .../mips/cavium-octeon/executive}/cvmx-cmd-queue.c |    8 +-
 .../mips/cavium-octeon/executive}/cvmx-fpa.c       |    0
 .../cavium-octeon/executive}/cvmx-helper-board.c   |   18 +--
 .../cavium-octeon/executive}/cvmx-helper-fpa.c     |    0
 .../cavium-octeon/executive}/cvmx-helper-loop.c    |    6 +-
 .../cavium-octeon/executive}/cvmx-helper-npi.c     |    6 +-
 .../cavium-octeon/executive}/cvmx-helper-rgmii.c   |   17 +-
 .../cavium-octeon/executive}/cvmx-helper-sgmii.c   |   12 +-
 .../cavium-octeon/executive}/cvmx-helper-spi.c     |   10 +-
 .../cavium-octeon/executive}/cvmx-helper-util.c    |   16 +-
 .../cavium-octeon/executive}/cvmx-helper-xaui.c    |   10 +-
 .../mips/cavium-octeon/executive}/cvmx-helper.c    |   27 ++--
 .../executive}/cvmx-interrupt-decodes.c            |   10 +-
 .../cavium-octeon/executive}/cvmx-interrupt-rsl.c  |    4 +-
 .../mips/cavium-octeon/executive}/cvmx-pko.c       |    8 +-
 .../mips/cavium-octeon/executive}/cvmx-spi.c       |   12 +-
 .../mips/include/asm}/octeon/cvmx-address.h        |    0
 .../mips/include/asm}/octeon/cvmx-asxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-cmd-queue.h      |    0
 .../mips/include/asm}/octeon/cvmx-config.h         |    0
 .../mips/include/asm}/octeon/cvmx-dbg-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-fau.h            |    0
 .../mips/include/asm}/octeon/cvmx-fpa-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-fpa.h            |    0
 .../mips/include/asm}/octeon/cvmx-gmxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-helper-board.h   |    0
 .../mips/include/asm}/octeon/cvmx-helper-fpa.h     |    0
 .../mips/include/asm}/octeon/cvmx-helper-loop.h    |    0
 .../mips/include/asm}/octeon/cvmx-helper-npi.h     |    0
 .../mips/include/asm}/octeon/cvmx-helper-rgmii.h   |    0
 .../mips/include/asm}/octeon/cvmx-helper-sgmii.h   |    0
 .../mips/include/asm}/octeon/cvmx-helper-spi.h     |    0
 .../mips/include/asm}/octeon/cvmx-helper-util.h    |    0
 .../mips/include/asm}/octeon/cvmx-helper-xaui.h    |    0
 .../mips/include/asm}/octeon/cvmx-helper.h         |    0
 .../mips/include/asm}/octeon/cvmx-ipd.h            |    0
 .../mips/include/asm}/octeon/cvmx-mdio.h           |    0
 .../mips/include/asm}/octeon/cvmx-pcsx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-pcsxx-defs.h     |    0
 .../mips/include/asm}/octeon/cvmx-pip-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-pip.h            |    0
 .../mips/include/asm}/octeon/cvmx-pko-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-pko.h            |    0
 .../mips/include/asm}/octeon/cvmx-pow.h            |    0
 .../mips/include/asm}/octeon/cvmx-scratch.h        |    0
 .../mips/include/asm}/octeon/cvmx-spi.h            |    0
 .../mips/include/asm}/octeon/cvmx-spxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-srxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-stxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-wqe.h            |    0
 drivers/staging/octeon/Makefile                    |    5 -
 drivers/staging/octeon/cvmx-packet.h               |   65 -------
 drivers/staging/octeon/cvmx-smix-defs.h            |  178 --------------------
 drivers/staging/octeon/ethernet-defines.h          |    2 +-
 drivers/staging/octeon/ethernet-mdio.c             |    4 +-
 drivers/staging/octeon/ethernet-mem.c              |    2 +-
 drivers/staging/octeon/ethernet-rgmii.c            |    4 +-
 drivers/staging/octeon/ethernet-rx.c               |   14 +-
 drivers/staging/octeon/ethernet-rx.h               |    2 +-
 drivers/staging/octeon/ethernet-sgmii.c            |    4 +-
 drivers/staging/octeon/ethernet-spi.c              |    6 +-
 drivers/staging/octeon/ethernet-tx.c               |   12 +-
 drivers/staging/octeon/ethernet-xaui.c             |    4 +-
 drivers/staging/octeon/ethernet.c                  |   14 +-
 65 files changed, 117 insertions(+), 368 deletions(-)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-cmd-queue.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-fpa.c (100%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-board.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-fpa.c (100%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-loop.c (95%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-npi.c (96%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-rgmii.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-sgmii.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-spi.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-util.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-xaui.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-interrupt-decodes.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-interrupt-rsl.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-pko.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-spi.c (99%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-address.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-asxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-cmd-queue.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-config.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-dbg-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fau.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fpa-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fpa.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-gmxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-board.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-fpa.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-loop.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-npi.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-rgmii.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-sgmii.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-spi.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-util.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-xaui.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-ipd.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-mdio.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pcsx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pcsxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pip-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pip.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pko-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pko.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pow.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-scratch.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-spi.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-spxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-srxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-stxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-wqe.h (100%)
 delete mode 100644 drivers/staging/octeon/cvmx-packet.h
 delete mode 100644 drivers/staging/octeon/cvmx-smix-defs.h

diff --git a/arch/mips/cavium-octeon/executive/Makefile b/arch/mips/cavium-octeon/executive/Makefile
index 7f41c5b..eec0b88 100644
--- a/arch/mips/cavium-octeon/executive/Makefile
+++ b/arch/mips/cavium-octeon/executive/Makefile
@@ -10,5 +10,10 @@
 #
 
 obj-y += cvmx-bootmem.o cvmx-l2c.o cvmx-sysinfo.o octeon-model.o
+obj-y += cvmx-pko.o cvmx-spi.o cvmx-cmd-queue.o \
+	cvmx-helper-board.o cvmx-helper.o cvmx-helper-xaui.o \
+	cvmx-helper-rgmii.o cvmx-helper-sgmii.o cvmx-helper-npi.o \
+	cvmx-helper-loop.o cvmx-helper-spi.o cvmx-helper-util.o \
+	cvmx-interrupt-decodes.o cvmx-interrupt-rsl.o
 
 obj-$(CONFIG_CAVIUM_OCTEON_HELPER) += cvmx-helper-errata.o cvmx-helper-jtag.o
diff --git a/drivers/staging/octeon/cvmx-cmd-queue.c b/arch/mips/cavium-octeon/executive/cvmx-cmd-queue.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-cmd-queue.c
rename to arch/mips/cavium-octeon/executive/cvmx-cmd-queue.c
index e9809d3..132bccc 100644
--- a/drivers/staging/octeon/cvmx-cmd-queue.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-cmd-queue.c
@@ -34,13 +34,13 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
-#include "cvmx-fpa.h"
-#include "cvmx-cmd-queue.h"
+#include <asm/octeon/cvmx-config.h>
+#include <asm/octeon/cvmx-fpa.h>
+#include <asm/octeon/cvmx-cmd-queue.h>
 
 #include <asm/octeon/cvmx-npei-defs.h>
 #include <asm/octeon/cvmx-pexp-defs.h>
-#include "cvmx-pko-defs.h"
+#include <asm/octeon/cvmx-pko-defs.h>
 
 /**
  * This application uses this pointer to access the global queue
diff --git a/drivers/staging/octeon/cvmx-fpa.c b/arch/mips/cavium-octeon/executive/cvmx-fpa.c
similarity index 100%
rename from drivers/staging/octeon/cvmx-fpa.c
rename to arch/mips/cavium-octeon/executive/cvmx-fpa.c
diff --git a/drivers/staging/octeon/cvmx-helper-board.c b/arch/mips/cavium-octeon/executive/cvmx-helper-board.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-helper-board.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-board.c
index 57d35dc..71590a3 100644
--- a/drivers/staging/octeon/cvmx-helper-board.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-board.c
@@ -34,16 +34,16 @@
 #include <asm/octeon/octeon.h>
 #include <asm/octeon/cvmx-bootinfo.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-mdio.h"
+#include <asm/octeon/cvmx-mdio.h>
 
-#include "cvmx-helper.h"
-#include "cvmx-helper-util.h"
-#include "cvmx-helper-board.h"
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-helper-util.h>
+#include <asm/octeon/cvmx-helper-board.h>
 
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-asxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-asxx-defs.h>
 
 /**
  * cvmx_override_board_link_get(int ipd_port) is a function
@@ -493,7 +493,6 @@ int cvmx_helper_board_link_set_phy(int phy_addr,
 		cvmx_mdio_phy_reg_control_t reg_control;
 		cvmx_mdio_phy_reg_status_t reg_status;
 		cvmx_mdio_phy_reg_autoneg_adver_t reg_autoneg_adver;
-		cvmx_mdio_phy_reg_extended_status_t reg_extended_status;
 		cvmx_mdio_phy_reg_control_1000_t reg_control_1000;
 
 		reg_status.u16 =
@@ -508,9 +507,6 @@ int cvmx_helper_board_link_set_phy(int phy_addr,
 		reg_autoneg_adver.s.advert_100base_tx_full = 0;
 		reg_autoneg_adver.s.advert_100base_tx_half = 0;
 		if (reg_status.s.capable_extended_status) {
-			reg_extended_status.u16 =
-			    cvmx_mdio_read(phy_addr >> 8, phy_addr & 0xff,
-					   CVMX_MDIO_PHY_REG_EXTENDED_STATUS);
 			reg_control_1000.u16 =
 			    cvmx_mdio_read(phy_addr >> 8, phy_addr & 0xff,
 					   CVMX_MDIO_PHY_REG_CONTROL_1000);
diff --git a/drivers/staging/octeon/cvmx-helper-fpa.c b/arch/mips/cavium-octeon/executive/cvmx-helper-fpa.c
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-fpa.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-fpa.c
diff --git a/drivers/staging/octeon/cvmx-helper-loop.c b/arch/mips/cavium-octeon/executive/cvmx-helper-loop.c
similarity index 95%
rename from drivers/staging/octeon/cvmx-helper-loop.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-loop.c
index 55a571a..bfbd461 100644
--- a/drivers/staging/octeon/cvmx-helper-loop.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-loop.c
@@ -31,10 +31,10 @@
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-helper.h"
-#include "cvmx-pip-defs.h"
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-pip-defs.h>
 
 /**
  * Probe a LOOP interface and determine the number of ports
diff --git a/drivers/staging/octeon/cvmx-helper-npi.c b/arch/mips/cavium-octeon/executive/cvmx-helper-npi.c
similarity index 96%
rename from drivers/staging/octeon/cvmx-helper-npi.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-npi.c
index 7388a1e..cc94cfa 100644
--- a/drivers/staging/octeon/cvmx-helper-npi.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-npi.c
@@ -31,11 +31,11 @@
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-pip-defs.h"
+#include <asm/octeon/cvmx-pip-defs.h>
 
 /**
  * Probe a NPI interface and determine the number of ports
diff --git a/drivers/staging/octeon/cvmx-helper-rgmii.c b/arch/mips/cavium-octeon/executive/cvmx-helper-rgmii.c
similarity index 97%
rename from drivers/staging/octeon/cvmx-helper-rgmii.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-rgmii.c
index aa2d5d7..82b2184 100644
--- a/drivers/staging/octeon/cvmx-helper-rgmii.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-rgmii.c
@@ -31,18 +31,18 @@
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
 
-#include "cvmx-mdio.h"
-#include "cvmx-pko.h"
-#include "cvmx-helper.h"
-#include "cvmx-helper-board.h"
+#include <asm/octeon/cvmx-mdio.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-helper-board.h>
 
 #include <asm/octeon/cvmx-npi-defs.h>
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-asxx-defs.h"
-#include "cvmx-dbg-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-asxx-defs.h>
+#include <asm/octeon/cvmx-dbg-defs.h>
 
 void __cvmx_interrupt_gmxx_enable(int interface);
 void __cvmx_interrupt_asxx_enable(int block);
@@ -326,6 +326,7 @@ int __cvmx_helper_rgmii_link_set(int ipd_port,
 		       cvmx_read_csr(CVMX_ASXX_RX_PRT_EN(interface)) &
 				     ~(1 << index));
 
+	memset(pko_mem_queue_qos_save, 0, sizeof(pko_mem_queue_qos_save));
 	/* Disable all queues so that TX should become idle */
 	for (i = 0; i < cvmx_pko_get_num_queues(ipd_port); i++) {
 		int queue = cvmx_pko_get_base_queue(ipd_port) + i;
diff --git a/drivers/staging/octeon/cvmx-helper-sgmii.c b/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-helper-sgmii.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
index 6214e3b..464347f 100644
--- a/drivers/staging/octeon/cvmx-helper-sgmii.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-sgmii.c
@@ -32,14 +32,14 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-mdio.h"
-#include "cvmx-helper.h"
-#include "cvmx-helper-board.h"
+#include <asm/octeon/cvmx-mdio.h>
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-helper-board.h>
 
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-pcsx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-pcsx-defs.h>
 
 void __cvmx_interrupt_gmxx_enable(int interface);
 void __cvmx_interrupt_pcsx_intx_en_reg_enable(int index, int block);
diff --git a/drivers/staging/octeon/cvmx-helper-spi.c b/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
similarity index 97%
rename from drivers/staging/octeon/cvmx-helper-spi.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
index 8ba6c83..02a4442 100644
--- a/drivers/staging/octeon/cvmx-helper-spi.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-spi.c
@@ -35,12 +35,12 @@ void __cvmx_interrupt_stxx_int_msk_enable(int index);
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
-#include "cvmx-spi.h"
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-config.h>
+#include <asm/octeon/cvmx-spi.h>
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-pip-defs.h"
-#include "cvmx-pko-defs.h"
+#include <asm/octeon/cvmx-pip-defs.h>
+#include <asm/octeon/cvmx-pko-defs.h>
 
 /*
  * CVMX_HELPER_SPI_TIMEOUT is used to determine how long the SPI
diff --git a/drivers/staging/octeon/cvmx-helper-util.c b/arch/mips/cavium-octeon/executive/cvmx-helper-util.c
similarity index 97%
rename from drivers/staging/octeon/cvmx-helper-util.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-util.c
index 131182b..116dea1 100644
--- a/drivers/staging/octeon/cvmx-helper-util.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-util.c
@@ -32,16 +32,16 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-fpa.h"
-#include "cvmx-pip.h"
-#include "cvmx-pko.h"
-#include "cvmx-ipd.h"
-#include "cvmx-spi.h"
+#include <asm/octeon/cvmx-fpa.h>
+#include <asm/octeon/cvmx-pip.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-ipd.h>
+#include <asm/octeon/cvmx-spi.h>
 
-#include "cvmx-helper.h"
-#include "cvmx-helper-util.h"
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-helper-util.h>
 
 #include <asm/octeon/cvmx-ipd-defs.h>
 
diff --git a/drivers/staging/octeon/cvmx-helper-xaui.c b/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-helper-xaui.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
index a11e676..667a8e3 100644
--- a/drivers/staging/octeon/cvmx-helper-xaui.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper-xaui.c
@@ -33,13 +33,13 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-pko-defs.h"
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-pcsxx-defs.h"
+#include <asm/octeon/cvmx-pko-defs.h>
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-pcsxx-defs.h>
 
 void __cvmx_interrupt_gmxx_enable(int interface);
 void __cvmx_interrupt_pcsx_intx_en_reg_enable(int index, int block);
diff --git a/drivers/staging/octeon/cvmx-helper.c b/arch/mips/cavium-octeon/executive/cvmx-helper.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-helper.c
rename to arch/mips/cavium-octeon/executive/cvmx-helper.c
index e9c5c83..daa8c8b 100644
--- a/drivers/staging/octeon/cvmx-helper.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-helper.c
@@ -32,19 +32,19 @@
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-fpa.h"
-#include "cvmx-pip.h"
-#include "cvmx-pko.h"
-#include "cvmx-ipd.h"
-#include "cvmx-spi.h"
-#include "cvmx-helper.h"
-#include "cvmx-helper-board.h"
+#include <asm/octeon/cvmx-fpa.h>
+#include <asm/octeon/cvmx-pip.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-ipd.h>
+#include <asm/octeon/cvmx-spi.h>
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-helper-board.h>
 
-#include "cvmx-pip-defs.h"
-#include "cvmx-smix-defs.h"
-#include "cvmx-asxx-defs.h"
+#include <asm/octeon/cvmx-pip-defs.h>
+#include <asm/octeon/cvmx-smix-defs.h>
+#include <asm/octeon/cvmx-asxx-defs.h>
 
 /**
  * cvmx_override_pko_queue_priority(int ipd_port, uint64_t
@@ -548,7 +548,6 @@ int __cvmx_helper_errata_fix_ipd_ptr_alignment(void)
 	union cvmx_gmxx_prtx_cfg gmx_cfg;
 	int retry_cnt;
 	int retry_loop_cnt;
-	int mtu;
 	int i;
 	cvmx_helper_link_info_t link_info;
 
@@ -662,10 +661,6 @@ int __cvmx_helper_errata_fix_ipd_ptr_alignment(void)
 		cvmx_write_csr(CVMX_ASXX_RX_PRT_EN(INTERFACE(FIX_IPD_OUTPORT)),
 			       1 << INDEX(FIX_IPD_OUTPORT));
 
-		mtu =
-		    cvmx_read_csr(CVMX_GMXX_RXX_JABBER
-				  (INDEX(FIX_IPD_OUTPORT),
-				   INTERFACE(FIX_IPD_OUTPORT)));
 		cvmx_write_csr(CVMX_GMXX_RXX_JABBER
 			       (INDEX(FIX_IPD_OUTPORT),
 				INTERFACE(FIX_IPD_OUTPORT)), 65392 - 14 - 4);
diff --git a/drivers/staging/octeon/cvmx-interrupt-decodes.c b/arch/mips/cavium-octeon/executive/cvmx-interrupt-decodes.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-interrupt-decodes.c
rename to arch/mips/cavium-octeon/executive/cvmx-interrupt-decodes.c
index a3337e3..e59d1b7 100644
--- a/drivers/staging/octeon/cvmx-interrupt-decodes.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-interrupt-decodes.c
@@ -34,11 +34,11 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-pcsx-defs.h"
-#include "cvmx-pcsxx-defs.h"
-#include "cvmx-spxx-defs.h"
-#include "cvmx-stxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-pcsx-defs.h>
+#include <asm/octeon/cvmx-pcsxx-defs.h>
+#include <asm/octeon/cvmx-spxx-defs.h>
+#include <asm/octeon/cvmx-stxx-defs.h>
 
 #ifndef PRINT_ERROR
 #define PRINT_ERROR(format, ...)
diff --git a/drivers/staging/octeon/cvmx-interrupt-rsl.c b/arch/mips/cavium-octeon/executive/cvmx-interrupt-rsl.c
similarity index 97%
rename from drivers/staging/octeon/cvmx-interrupt-rsl.c
rename to arch/mips/cavium-octeon/executive/cvmx-interrupt-rsl.c
index df50048..bea7538 100644
--- a/drivers/staging/octeon/cvmx-interrupt-rsl.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-interrupt-rsl.c
@@ -32,8 +32,8 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-asxx-defs.h"
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-asxx-defs.h>
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 #ifndef PRINT_ERROR
 #define PRINT_ERROR(format, ...)
diff --git a/drivers/staging/octeon/cvmx-pko.c b/arch/mips/cavium-octeon/executive/cvmx-pko.c
similarity index 98%
rename from drivers/staging/octeon/cvmx-pko.c
rename to arch/mips/cavium-octeon/executive/cvmx-pko.c
index 50a2c9b..f557084 100644
--- a/drivers/staging/octeon/cvmx-pko.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-pko.c
@@ -31,9 +31,9 @@
 
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
-#include "cvmx-pko.h"
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-config.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-helper.h>
 
 /**
  * Internal state of packet output
@@ -54,7 +54,7 @@ void cvmx_pko_initialize_global(void)
 	/*
 	 * Set the size of the PKO command buffers to an odd number of
 	 * 64bit words. This allows the normal two word send to stay
-	 * aligned and never span a command word buffer.
+	 * aligned and never span a comamnd word buffer.
 	 */
 	config.u64 = 0;
 	config.s.pool = CVMX_FPA_OUTPUT_BUFFER_POOL;
diff --git a/drivers/staging/octeon/cvmx-spi.c b/arch/mips/cavium-octeon/executive/cvmx-spi.c
similarity index 99%
rename from drivers/staging/octeon/cvmx-spi.c
rename to arch/mips/cavium-octeon/executive/cvmx-spi.c
index 82794d9..74afb17 100644
--- a/drivers/staging/octeon/cvmx-spi.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-spi.c
@@ -31,14 +31,14 @@
  */
 #include <asm/octeon/octeon.h>
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
-#include "cvmx-pko.h"
-#include "cvmx-spi.h"
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-spi.h>
 
-#include "cvmx-spxx-defs.h"
-#include "cvmx-stxx-defs.h"
-#include "cvmx-srxx-defs.h"
+#include <asm/octeon/cvmx-spxx-defs.h>
+#include <asm/octeon/cvmx-stxx-defs.h>
+#include <asm/octeon/cvmx-srxx-defs.h>
 
 #define INVOKE_CB(function_p, args...)		\
 	do {					\
diff --git a/drivers/staging/octeon/cvmx-address.h b/arch/mips/include/asm/octeon/cvmx-address.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-address.h
rename to arch/mips/include/asm/octeon/cvmx-address.h
diff --git a/drivers/staging/octeon/cvmx-asxx-defs.h b/arch/mips/include/asm/octeon/cvmx-asxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-asxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-asxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-cmd-queue.h b/arch/mips/include/asm/octeon/cvmx-cmd-queue.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-cmd-queue.h
rename to arch/mips/include/asm/octeon/cvmx-cmd-queue.h
diff --git a/drivers/staging/octeon/cvmx-config.h b/arch/mips/include/asm/octeon/cvmx-config.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-config.h
rename to arch/mips/include/asm/octeon/cvmx-config.h
diff --git a/drivers/staging/octeon/cvmx-dbg-defs.h b/arch/mips/include/asm/octeon/cvmx-dbg-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-dbg-defs.h
rename to arch/mips/include/asm/octeon/cvmx-dbg-defs.h
diff --git a/drivers/staging/octeon/cvmx-fau.h b/arch/mips/include/asm/octeon/cvmx-fau.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-fau.h
rename to arch/mips/include/asm/octeon/cvmx-fau.h
diff --git a/drivers/staging/octeon/cvmx-fpa-defs.h b/arch/mips/include/asm/octeon/cvmx-fpa-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-fpa-defs.h
rename to arch/mips/include/asm/octeon/cvmx-fpa-defs.h
diff --git a/drivers/staging/octeon/cvmx-fpa.h b/arch/mips/include/asm/octeon/cvmx-fpa.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-fpa.h
rename to arch/mips/include/asm/octeon/cvmx-fpa.h
diff --git a/drivers/staging/octeon/cvmx-gmxx-defs.h b/arch/mips/include/asm/octeon/cvmx-gmxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-gmxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-gmxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-helper-board.h b/arch/mips/include/asm/octeon/cvmx-helper-board.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-board.h
rename to arch/mips/include/asm/octeon/cvmx-helper-board.h
diff --git a/drivers/staging/octeon/cvmx-helper-fpa.h b/arch/mips/include/asm/octeon/cvmx-helper-fpa.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-fpa.h
rename to arch/mips/include/asm/octeon/cvmx-helper-fpa.h
diff --git a/drivers/staging/octeon/cvmx-helper-loop.h b/arch/mips/include/asm/octeon/cvmx-helper-loop.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-loop.h
rename to arch/mips/include/asm/octeon/cvmx-helper-loop.h
diff --git a/drivers/staging/octeon/cvmx-helper-npi.h b/arch/mips/include/asm/octeon/cvmx-helper-npi.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-npi.h
rename to arch/mips/include/asm/octeon/cvmx-helper-npi.h
diff --git a/drivers/staging/octeon/cvmx-helper-rgmii.h b/arch/mips/include/asm/octeon/cvmx-helper-rgmii.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-rgmii.h
rename to arch/mips/include/asm/octeon/cvmx-helper-rgmii.h
diff --git a/drivers/staging/octeon/cvmx-helper-sgmii.h b/arch/mips/include/asm/octeon/cvmx-helper-sgmii.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-sgmii.h
rename to arch/mips/include/asm/octeon/cvmx-helper-sgmii.h
diff --git a/drivers/staging/octeon/cvmx-helper-spi.h b/arch/mips/include/asm/octeon/cvmx-helper-spi.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-spi.h
rename to arch/mips/include/asm/octeon/cvmx-helper-spi.h
diff --git a/drivers/staging/octeon/cvmx-helper-util.h b/arch/mips/include/asm/octeon/cvmx-helper-util.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-util.h
rename to arch/mips/include/asm/octeon/cvmx-helper-util.h
diff --git a/drivers/staging/octeon/cvmx-helper-xaui.h b/arch/mips/include/asm/octeon/cvmx-helper-xaui.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper-xaui.h
rename to arch/mips/include/asm/octeon/cvmx-helper-xaui.h
diff --git a/drivers/staging/octeon/cvmx-helper.h b/arch/mips/include/asm/octeon/cvmx-helper.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-helper.h
rename to arch/mips/include/asm/octeon/cvmx-helper.h
diff --git a/drivers/staging/octeon/cvmx-ipd.h b/arch/mips/include/asm/octeon/cvmx-ipd.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-ipd.h
rename to arch/mips/include/asm/octeon/cvmx-ipd.h
diff --git a/drivers/staging/octeon/cvmx-mdio.h b/arch/mips/include/asm/octeon/cvmx-mdio.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-mdio.h
rename to arch/mips/include/asm/octeon/cvmx-mdio.h
diff --git a/drivers/staging/octeon/cvmx-pcsx-defs.h b/arch/mips/include/asm/octeon/cvmx-pcsx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pcsx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-pcsx-defs.h
diff --git a/drivers/staging/octeon/cvmx-pcsxx-defs.h b/arch/mips/include/asm/octeon/cvmx-pcsxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pcsxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-pcsxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-pip-defs.h b/arch/mips/include/asm/octeon/cvmx-pip-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pip-defs.h
rename to arch/mips/include/asm/octeon/cvmx-pip-defs.h
diff --git a/drivers/staging/octeon/cvmx-pip.h b/arch/mips/include/asm/octeon/cvmx-pip.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pip.h
rename to arch/mips/include/asm/octeon/cvmx-pip.h
diff --git a/drivers/staging/octeon/cvmx-pko-defs.h b/arch/mips/include/asm/octeon/cvmx-pko-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pko-defs.h
rename to arch/mips/include/asm/octeon/cvmx-pko-defs.h
diff --git a/drivers/staging/octeon/cvmx-pko.h b/arch/mips/include/asm/octeon/cvmx-pko.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pko.h
rename to arch/mips/include/asm/octeon/cvmx-pko.h
diff --git a/drivers/staging/octeon/cvmx-pow.h b/arch/mips/include/asm/octeon/cvmx-pow.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-pow.h
rename to arch/mips/include/asm/octeon/cvmx-pow.h
diff --git a/drivers/staging/octeon/cvmx-scratch.h b/arch/mips/include/asm/octeon/cvmx-scratch.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-scratch.h
rename to arch/mips/include/asm/octeon/cvmx-scratch.h
diff --git a/drivers/staging/octeon/cvmx-spi.h b/arch/mips/include/asm/octeon/cvmx-spi.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-spi.h
rename to arch/mips/include/asm/octeon/cvmx-spi.h
diff --git a/drivers/staging/octeon/cvmx-spxx-defs.h b/arch/mips/include/asm/octeon/cvmx-spxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-spxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-spxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-srxx-defs.h b/arch/mips/include/asm/octeon/cvmx-srxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-srxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-srxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-stxx-defs.h b/arch/mips/include/asm/octeon/cvmx-stxx-defs.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-stxx-defs.h
rename to arch/mips/include/asm/octeon/cvmx-stxx-defs.h
diff --git a/drivers/staging/octeon/cvmx-wqe.h b/arch/mips/include/asm/octeon/cvmx-wqe.h
similarity index 100%
rename from drivers/staging/octeon/cvmx-wqe.h
rename to arch/mips/include/asm/octeon/cvmx-wqe.h
diff --git a/drivers/staging/octeon/Makefile b/drivers/staging/octeon/Makefile
index fc850ba..9012dee 100644
--- a/drivers/staging/octeon/Makefile
+++ b/drivers/staging/octeon/Makefile
@@ -20,9 +20,4 @@ octeon-ethernet-y += ethernet-sgmii.o
 octeon-ethernet-y += ethernet-spi.o
 octeon-ethernet-y += ethernet-tx.o
 octeon-ethernet-y += ethernet-xaui.o
-octeon-ethernet-y += cvmx-pko.o cvmx-spi.o cvmx-cmd-queue.o \
-	cvmx-helper-board.o cvmx-helper.o cvmx-helper-xaui.o \
-	cvmx-helper-rgmii.o cvmx-helper-sgmii.o cvmx-helper-npi.o \
-	cvmx-helper-loop.o cvmx-helper-spi.o cvmx-helper-util.o \
-	cvmx-interrupt-decodes.o cvmx-interrupt-rsl.o
 
diff --git a/drivers/staging/octeon/cvmx-packet.h b/drivers/staging/octeon/cvmx-packet.h
deleted file mode 100644
index 62ffe78..0000000
--- a/drivers/staging/octeon/cvmx-packet.h
+++ /dev/null
@@ -1,65 +0,0 @@
-/***********************license start***************
- * Author: Cavium Networks
- *
- * Contact: support@caviumnetworks.com
- * This file is part of the OCTEON SDK
- *
- * Copyright (c) 2003-2008 Cavium Networks
- *
- * This file is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License, Version 2, as
- * published by the Free Software Foundation.
- *
- * This file is distributed in the hope that it will be useful, but
- * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
- * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this file; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
- * or visit http://www.gnu.org/licenses/.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium Networks for more information
- ***********************license end**************************************/
-
-/**
- *
- * Packet buffer defines.
- */
-
-#ifndef __CVMX_PACKET_H__
-#define __CVMX_PACKET_H__
-
-/**
- * This structure defines a buffer pointer on Octeon
- */
-union cvmx_buf_ptr {
-	void *ptr;
-	uint64_t u64;
-	struct {
-		/*
-		 * if set, invert the "free" pick of the overall
-		 * packet. HW always sets this bit to 0 on inbound
-		 * packet
-		 */
-		uint64_t i:1;
-		/*
-		 * Indicates the amount to back up to get to the
-		 * buffer start in cache lines. In most cases this is
-		 * less than one complete cache line, so the value is
-		 * zero.
-		 */
-		uint64_t back:4;
-		/* The pool that the buffer came from / goes to */
-		uint64_t pool:3;
-		/* The size of the segment pointed to by addr (in bytes) */
-		uint64_t size:16;
-		/* Pointer to the first byte of the data, NOT buffer */
-		uint64_t addr:40;
-	} s;
-};
-
-#endif /*  __CVMX_PACKET_H__ */
diff --git a/drivers/staging/octeon/cvmx-smix-defs.h b/drivers/staging/octeon/cvmx-smix-defs.h
deleted file mode 100644
index 9ae45fc..0000000
--- a/drivers/staging/octeon/cvmx-smix-defs.h
+++ /dev/null
@@ -1,178 +0,0 @@
-/***********************license start***************
- * Author: Cavium Networks
- *
- * Contact: support@caviumnetworks.com
- * This file is part of the OCTEON SDK
- *
- * Copyright (c) 2003-2008 Cavium Networks
- *
- * This file is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License, Version 2, as
- * published by the Free Software Foundation.
- *
- * This file is distributed in the hope that it will be useful, but
- * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
- * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this file; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
- * or visit http://www.gnu.org/licenses/.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium Networks for more information
- ***********************license end**************************************/
-
-#ifndef __CVMX_SMIX_DEFS_H__
-#define __CVMX_SMIX_DEFS_H__
-
-#define CVMX_SMIX_CLK(offset) \
-	 CVMX_ADD_IO_SEG(0x0001180000001818ull + (((offset) & 1) * 256))
-#define CVMX_SMIX_CMD(offset) \
-	 CVMX_ADD_IO_SEG(0x0001180000001800ull + (((offset) & 1) * 256))
-#define CVMX_SMIX_EN(offset) \
-	 CVMX_ADD_IO_SEG(0x0001180000001820ull + (((offset) & 1) * 256))
-#define CVMX_SMIX_RD_DAT(offset) \
-	 CVMX_ADD_IO_SEG(0x0001180000001810ull + (((offset) & 1) * 256))
-#define CVMX_SMIX_WR_DAT(offset) \
-	 CVMX_ADD_IO_SEG(0x0001180000001808ull + (((offset) & 1) * 256))
-
-union cvmx_smix_clk {
-	uint64_t u64;
-	struct cvmx_smix_clk_s {
-		uint64_t reserved_25_63:39;
-		uint64_t mode:1;
-		uint64_t reserved_21_23:3;
-		uint64_t sample_hi:5;
-		uint64_t sample_mode:1;
-		uint64_t reserved_14_14:1;
-		uint64_t clk_idle:1;
-		uint64_t preamble:1;
-		uint64_t sample:4;
-		uint64_t phase:8;
-	} s;
-	struct cvmx_smix_clk_cn30xx {
-		uint64_t reserved_21_63:43;
-		uint64_t sample_hi:5;
-		uint64_t reserved_14_15:2;
-		uint64_t clk_idle:1;
-		uint64_t preamble:1;
-		uint64_t sample:4;
-		uint64_t phase:8;
-	} cn30xx;
-	struct cvmx_smix_clk_cn30xx cn31xx;
-	struct cvmx_smix_clk_cn30xx cn38xx;
-	struct cvmx_smix_clk_cn30xx cn38xxp2;
-	struct cvmx_smix_clk_cn50xx {
-		uint64_t reserved_25_63:39;
-		uint64_t mode:1;
-		uint64_t reserved_21_23:3;
-		uint64_t sample_hi:5;
-		uint64_t reserved_14_15:2;
-		uint64_t clk_idle:1;
-		uint64_t preamble:1;
-		uint64_t sample:4;
-		uint64_t phase:8;
-	} cn50xx;
-	struct cvmx_smix_clk_s cn52xx;
-	struct cvmx_smix_clk_cn50xx cn52xxp1;
-	struct cvmx_smix_clk_s cn56xx;
-	struct cvmx_smix_clk_cn50xx cn56xxp1;
-	struct cvmx_smix_clk_cn30xx cn58xx;
-	struct cvmx_smix_clk_cn30xx cn58xxp1;
-};
-
-union cvmx_smix_cmd {
-	uint64_t u64;
-	struct cvmx_smix_cmd_s {
-		uint64_t reserved_18_63:46;
-		uint64_t phy_op:2;
-		uint64_t reserved_13_15:3;
-		uint64_t phy_adr:5;
-		uint64_t reserved_5_7:3;
-		uint64_t reg_adr:5;
-	} s;
-	struct cvmx_smix_cmd_cn30xx {
-		uint64_t reserved_17_63:47;
-		uint64_t phy_op:1;
-		uint64_t reserved_13_15:3;
-		uint64_t phy_adr:5;
-		uint64_t reserved_5_7:3;
-		uint64_t reg_adr:5;
-	} cn30xx;
-	struct cvmx_smix_cmd_cn30xx cn31xx;
-	struct cvmx_smix_cmd_cn30xx cn38xx;
-	struct cvmx_smix_cmd_cn30xx cn38xxp2;
-	struct cvmx_smix_cmd_s cn50xx;
-	struct cvmx_smix_cmd_s cn52xx;
-	struct cvmx_smix_cmd_s cn52xxp1;
-	struct cvmx_smix_cmd_s cn56xx;
-	struct cvmx_smix_cmd_s cn56xxp1;
-	struct cvmx_smix_cmd_cn30xx cn58xx;
-	struct cvmx_smix_cmd_cn30xx cn58xxp1;
-};
-
-union cvmx_smix_en {
-	uint64_t u64;
-	struct cvmx_smix_en_s {
-		uint64_t reserved_1_63:63;
-		uint64_t en:1;
-	} s;
-	struct cvmx_smix_en_s cn30xx;
-	struct cvmx_smix_en_s cn31xx;
-	struct cvmx_smix_en_s cn38xx;
-	struct cvmx_smix_en_s cn38xxp2;
-	struct cvmx_smix_en_s cn50xx;
-	struct cvmx_smix_en_s cn52xx;
-	struct cvmx_smix_en_s cn52xxp1;
-	struct cvmx_smix_en_s cn56xx;
-	struct cvmx_smix_en_s cn56xxp1;
-	struct cvmx_smix_en_s cn58xx;
-	struct cvmx_smix_en_s cn58xxp1;
-};
-
-union cvmx_smix_rd_dat {
-	uint64_t u64;
-	struct cvmx_smix_rd_dat_s {
-		uint64_t reserved_18_63:46;
-		uint64_t pending:1;
-		uint64_t val:1;
-		uint64_t dat:16;
-	} s;
-	struct cvmx_smix_rd_dat_s cn30xx;
-	struct cvmx_smix_rd_dat_s cn31xx;
-	struct cvmx_smix_rd_dat_s cn38xx;
-	struct cvmx_smix_rd_dat_s cn38xxp2;
-	struct cvmx_smix_rd_dat_s cn50xx;
-	struct cvmx_smix_rd_dat_s cn52xx;
-	struct cvmx_smix_rd_dat_s cn52xxp1;
-	struct cvmx_smix_rd_dat_s cn56xx;
-	struct cvmx_smix_rd_dat_s cn56xxp1;
-	struct cvmx_smix_rd_dat_s cn58xx;
-	struct cvmx_smix_rd_dat_s cn58xxp1;
-};
-
-union cvmx_smix_wr_dat {
-	uint64_t u64;
-	struct cvmx_smix_wr_dat_s {
-		uint64_t reserved_18_63:46;
-		uint64_t pending:1;
-		uint64_t val:1;
-		uint64_t dat:16;
-	} s;
-	struct cvmx_smix_wr_dat_s cn30xx;
-	struct cvmx_smix_wr_dat_s cn31xx;
-	struct cvmx_smix_wr_dat_s cn38xx;
-	struct cvmx_smix_wr_dat_s cn38xxp2;
-	struct cvmx_smix_wr_dat_s cn50xx;
-	struct cvmx_smix_wr_dat_s cn52xx;
-	struct cvmx_smix_wr_dat_s cn52xxp1;
-	struct cvmx_smix_wr_dat_s cn56xx;
-	struct cvmx_smix_wr_dat_s cn56xxp1;
-	struct cvmx_smix_wr_dat_s cn58xx;
-	struct cvmx_smix_wr_dat_s cn58xxp1;
-};
-
-#endif
diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index 6a2cd50..bdaec8d 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -59,7 +59,7 @@
 #ifndef __ETHERNET_DEFINES_H__
 #define __ETHERNET_DEFINES_H__
 
-#include "cvmx-config.h"
+#include <asm/octeon/cvmx-config.h>
 
 
 #define OCTEON_ETHERNET_VERSION "1.9"
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index f18e3e1..63800ba 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -38,9 +38,9 @@
 #include "ethernet-mdio.h"
 #include "ethernet-util.h"
 
-#include "cvmx-helper-board.h"
+#include <asm/octeon/cvmx-helper-board.h>
 
-#include "cvmx-smix-defs.h"
+#include <asm/octeon/cvmx-smix-defs.h>
 
 static void cvm_oct_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
diff --git a/drivers/staging/octeon/ethernet-mem.c b/drivers/staging/octeon/ethernet-mem.c
index 635bb86..78b6cb7 100644
--- a/drivers/staging/octeon/ethernet-mem.c
+++ b/drivers/staging/octeon/ethernet-mem.c
@@ -32,7 +32,7 @@
 
 #include "ethernet-defines.h"
 
-#include "cvmx-fpa.h"
+#include <asm/octeon/cvmx-fpa.h>
 
 /**
  * cvm_oct_fill_hw_skbuff - fill the supplied hardware pool with skbuffs
diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index c3d73f8..d8f5f69 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -37,11 +37,11 @@
 #include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-helper.h>
 
 #include <asm/octeon/cvmx-ipd-defs.h>
 #include <asm/octeon/cvmx-npi-defs.h>
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 DEFINE_SPINLOCK(global_register_lock);
 
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index 8b307b4..400df8c 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -52,14 +52,14 @@
 #include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
-#include "cvmx-helper.h"
-#include "cvmx-wqe.h"
-#include "cvmx-fau.h"
-#include "cvmx-pow.h"
-#include "cvmx-pip.h"
-#include "cvmx-scratch.h"
-
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-helper.h>
+#include <asm/octeon/cvmx-wqe.h>
+#include <asm/octeon/cvmx-fau.h>
+#include <asm/octeon/cvmx-pow.h>
+#include <asm/octeon/cvmx-pip.h>
+#include <asm/octeon/cvmx-scratch.h>
+
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 struct cvm_napi_wrapper {
 	struct napi_struct napi;
diff --git a/drivers/staging/octeon/ethernet-rx.h b/drivers/staging/octeon/ethernet-rx.h
index a0743b8..9240c85 100644
--- a/drivers/staging/octeon/ethernet-rx.h
+++ b/drivers/staging/octeon/ethernet-rx.h
@@ -24,7 +24,7 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium Networks for more information
 *********************************************************************/
-#include "cvmx-fau.h"
+#include <asm/octeon/cvmx-fau.h>
 
 void cvm_oct_poll_controller(struct net_device *dev);
 void cvm_oct_rx_initialize(void);
diff --git a/drivers/staging/octeon/ethernet-sgmii.c b/drivers/staging/octeon/ethernet-sgmii.c
index 5e148b5..d3e8243 100644
--- a/drivers/staging/octeon/ethernet-sgmii.c
+++ b/drivers/staging/octeon/ethernet-sgmii.c
@@ -35,9 +35,9 @@
 #include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 int cvm_oct_sgmii_open(struct net_device *dev)
 {
diff --git a/drivers/staging/octeon/ethernet-spi.c b/drivers/staging/octeon/ethernet-spi.c
index d0e2d51..af8d628 100644
--- a/drivers/staging/octeon/ethernet-spi.c
+++ b/drivers/staging/octeon/ethernet-spi.c
@@ -35,11 +35,11 @@
 #include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
-#include "cvmx-spi.h"
+#include <asm/octeon/cvmx-spi.h>
 
 #include <asm/octeon/cvmx-npi-defs.h>
-#include "cvmx-spxx-defs.h"
-#include "cvmx-stxx-defs.h"
+#include <asm/octeon/cvmx-spxx-defs.h>
+#include <asm/octeon/cvmx-stxx-defs.h>
 
 static int number_spi_ports;
 static int need_retrain[2] = { 0, 0 };
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 2542c37..56d74dc 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -47,13 +47,13 @@
 #include "ethernet-tx.h"
 #include "ethernet-util.h"
 
-#include "cvmx-wqe.h"
-#include "cvmx-fau.h"
-#include "cvmx-pip.h"
-#include "cvmx-pko.h"
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-wqe.h>
+#include <asm/octeon/cvmx-fau.h>
+#include <asm/octeon/cvmx-pip.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 #define CVM_OCT_SKB_CB(skb)	((u64 *)((skb)->cb))
 
diff --git a/drivers/staging/octeon/ethernet-xaui.c b/drivers/staging/octeon/ethernet-xaui.c
index 861a4b3..419f8c3 100644
--- a/drivers/staging/octeon/ethernet-xaui.c
+++ b/drivers/staging/octeon/ethernet-xaui.c
@@ -35,9 +35,9 @@
 #include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
-#include "cvmx-helper.h"
+#include <asm/octeon/cvmx-helper.h>
 
-#include "cvmx-gmxx-defs.h"
+#include <asm/octeon/cvmx-gmxx-defs.h>
 
 int cvm_oct_xaui_open(struct net_device *dev)
 {
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 076f866..9112cd8 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -44,14 +44,14 @@
 #include "ethernet-mdio.h"
 #include "ethernet-util.h"
 
-#include "cvmx-pip.h"
-#include "cvmx-pko.h"
-#include "cvmx-fau.h"
-#include "cvmx-ipd.h"
-#include "cvmx-helper.h"
-
-#include "cvmx-gmxx-defs.h"
-#include "cvmx-smix-defs.h"
+#include <asm/octeon/cvmx-pip.h>
+#include <asm/octeon/cvmx-pko.h>
+#include <asm/octeon/cvmx-fau.h>
+#include <asm/octeon/cvmx-ipd.h>
+#include <asm/octeon/cvmx-helper.h>
+
+#include <asm/octeon/cvmx-gmxx-defs.h>
+#include <asm/octeon/cvmx-smix-defs.h>
 
 #if defined(CONFIG_CAVIUM_OCTEON_NUM_PACKET_BUFFERS) \
 	&& CONFIG_CAVIUM_OCTEON_NUM_PACKET_BUFFERS
-- 
1.7.2.3
