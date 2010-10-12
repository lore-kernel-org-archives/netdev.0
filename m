From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [RFC arm-kernel 4/4] caif-u5500: Build config for CAIF shared mem driver
Date: Tue, 12 Oct 2010 13:10:21 +0200
Message-ID: <1286881821-2916-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan.xk.nilsson@stericsson.com, linus.walleij@stericsson.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kim.lilliestierna@stericsson.com, daniel.martensson@stericsson.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33946 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183Ab0JLLK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 07:10:58 -0400
Received: by mail-ew0-f46.google.com with SMTP id 20so1136102ewy.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 04:10:58 -0700 (PDT)
In-Reply-To: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
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
 	help to synchronize to the next transfer in case of over or under-run=
s.
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
@@ -8,3 +8,7 @@ obj-$(CONFIG_CAIF_TTY) +=3D caif_serial.o
 # SPI slave physical interfaces module
 cfspi_slave-objs :=3D caif_spi.o caif_spi_slave.o
 obj-$(CONFIG_CAIF_SPI_SLAVE) +=3D cfspi_slave.o
+
+# Shared memory
+caif_shm-objs :=3D caif_shmcore.o caif_shm_u5500.o
+obj-$(CONFIG_CAIF_SHM) +=3D caif_shm.o
--=20
1.7.0.4

