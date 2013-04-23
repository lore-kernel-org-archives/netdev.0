From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 3/4] caif: Remove bouncing address for Daniel Martensson
Date: Tue, 23 Apr 2013 11:57:02 +0200
Message-ID: <1366711023-2977-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1366711023-2977-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>, sjur@brendeland.net,
	netdev@vger.kernel.org,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	Daniel Martensson <Daniel.Martensson@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:59895 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985Ab3DWJ5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 05:57:33 -0400
Received: by mail-la0-f47.google.com with SMTP id ez20so366453lab.20
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 02:57:31 -0700 (PDT)
In-Reply-To: <1366711023-2977-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc: Daniel Martensson <Daniel.Martensson@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
--
Daniel's address will soon start bouncing (May 1st).
---
 drivers/net/caif/caif_hsi.c       |    4 ++--
 drivers/net/caif/caif_spi.c       |    4 ++--
 drivers/net/caif/caif_spi_slave.c |    2 +-
 net/caif/chnl_net.c               |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 77f5074..a6af619 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:  Daniel Martensson / daniel.martensson@stericsson.com
+ * Author:  Daniel Martensson
  *	    Dmitry.Tarnyagin  / dmitry.tarnyagin@stericsson.com
  * License terms: GNU General Public License (GPL) version 2.
  */
@@ -24,7 +24,7 @@
 #include <net/caif/caif_hsi.h>
=20
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Daniel Martensson<daniel.martensson@stericsson.com>");
+MODULE_AUTHOR("Daniel Martensson");
 MODULE_DESCRIPTION("CAIF HSI driver");
=20
 /* Returns the number of padding bytes for alignment. */
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index c2cb852..2fb279a 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
+ * Author:  Daniel Martensson
  * License terms: GNU General Public License (GPL) version 2.
  */
=20
@@ -28,7 +28,7 @@
 #endif /* CONFIG_CAIF_SPI_SYNC */
=20
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Daniel Martensson<daniel.martensson@stericsson.com>");
+MODULE_AUTHOR("Daniel Martensson");
 MODULE_DESCRIPTION("CAIF SPI driver");
=20
 /* Returns the number of padding bytes for alignment. */
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_=
spi_slave.c
index 98f0366..ee92ad5 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
+ * Author:  Daniel Martensson
  * License terms: GNU General Public License (GPL) version 2.
  */
 #include <linux/init.h>
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 89586c0..7344a8f 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
  * Authors:	Sjur Brendeland
- *		Daniel Martensson / Daniel.Martensson@stericsson.com
+ *		Daniel Martensson
  * License terms: GNU General Public License (GPL) version 2
  */
=20
--=20
1.7.5.4
