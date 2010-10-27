From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 4/4] caif-u5500: Build config for CAIF shared mem driver
Date: Wed, 27 Oct 2010 20:34:42 +0200
Message-ID: <1288204482-2742-4-git-send-email-sjur.brandeland@stericsson.com>
References: <20101027.110732.48492064.davem@davemloft.net>
 <1288204482-2742-1-git-send-email-sjur.brandeland@stericsson.com>
 <1288204482-2742-2-git-send-email-sjur.brandeland@stericsson.com>
 <1288204482-2742-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Russel King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linus.walleij@stericsson.com,
	stefan.xk.nilsson@stericsson.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:41187 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab0J0SfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:35:06 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LAY00A27OYGL960@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 27 Oct 2010 20:35:04 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.37])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LAY0006ZOYBC7A0@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 27 Oct 2010 20:35:04 +0200 (CEST)
In-reply-to: <1288204482-2742-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/Kconfig  |    7 +++++++
 drivers/net/caif/Makefile |    4 ++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 75bfc3a..09ed3f4 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -31,3 +31,10 @@ config CAIF_SPI_SYNC
 	Putting the next command and length in the start of the frame can
 	help to synchronize to the next transfer in case of over or under-runs.
 	This option also needs to be enabled on the modem.
+
+config CAIF_SHM
+	tristate "CAIF shared memory protocol driver"
+	depends on CAIF && U5500_MBOX
+	default n
+	---help---
+	The CAIF shared memory protocol driver for the STE UX5500 platform.
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
index 3a11d61..b38d987 100644
--- a/drivers/net/caif/Makefile
+++ b/drivers/net/caif/Makefile
@@ -8,3 +8,7 @@ obj-$(CONFIG_CAIF_TTY) += caif_serial.o
 # SPI slave physical interfaces module
 cfspi_slave-objs := caif_spi.o caif_spi_slave.o
 obj-$(CONFIG_CAIF_SPI_SLAVE) += cfspi_slave.o
+
+# Shared memory
+caif_shm-objs := caif_shmcore.o caif_shm_u5500.o
+obj-$(CONFIG_CAIF_SHM) += caif_shm.o
-- 
1.6.3.3

