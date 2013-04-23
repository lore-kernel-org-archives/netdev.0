From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 2/4] caif: Remove my bouncing email address.
Date: Tue, 23 Apr 2013 11:57:01 +0200
Message-ID: <1366711023-2977-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1366711023-2977-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>, sjur@brendeland.net,
	netdev@vger.kernel.org,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:65402 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985Ab3DWJ53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 05:57:29 -0400
Received: by mail-la0-f48.google.com with SMTP id eo20so366717lab.21
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 02:57:28 -0700 (PDT)
In-Reply-To: <1366711023-2977-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove my soon bouncing email address.
Also remove the "Contact:" line in file header.
The MAINTAINERS file is a better place to find the
contact person anyway.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
My stericsson email will start bouncing by end of
this month.

Cheers,
Sjur

 drivers/net/caif/caif_hsi.c           |    1 -
 drivers/net/caif/caif_serial.c        |    4 ++--
 drivers/net/caif/caif_spi.c           |    1 -
 drivers/net/caif/caif_spi_slave.c     |    1 -
 include/net/caif/caif_dev.h           |    2 +-
 include/net/caif/caif_device.h        |    2 +-
 include/net/caif/caif_hsi.h           |    1 -
 include/net/caif/caif_layer.h         |    2 +-
 include/net/caif/cfcnfg.h             |    2 +-
 include/net/caif/cfctrl.h             |    2 +-
 include/net/caif/cffrml.h             |    2 +-
 include/net/caif/cfmuxl.h             |    2 +-
 include/net/caif/cfpkt.h              |    2 +-
 include/net/caif/cfserl.h             |    2 +-
 include/net/caif/cfsrvl.h             |    2 +-
 include/uapi/linux/caif/caif_socket.h |    2 +-
 include/uapi/linux/caif/if_caif.h     |    2 +-
 net/caif/caif_dev.c                   |    2 +-
 net/caif/caif_socket.c                |    2 +-
 net/caif/caif_usb.c                   |    2 +-
 net/caif/cfcnfg.c                     |    2 +-
 net/caif/cfctrl.c                     |    2 +-
 net/caif/cfdbgl.c                     |    2 +-
 net/caif/cfdgml.c                     |    2 +-
 net/caif/cffrml.c                     |    2 +-
 net/caif/cfmuxl.c                     |    2 +-
 net/caif/cfpkt_skbuff.c               |    2 +-
 net/caif/cfrfml.c                     |    2 +-
 net/caif/cfserl.c                     |    2 +-
 net/caif/cfsrvl.c                     |    2 +-
 net/caif/cfutill.c                    |    2 +-
 net/caif/cfveil.c                     |    2 +-
 net/caif/cfvidl.c                     |    2 +-
 net/caif/chnl_net.c                   |    2 +-
 34 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 0def8b3..77f5074 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
  * Author:  Daniel Martensson / daniel.martensson@stericsson.com
  *	    Dmitry.Tarnyagin  / dmitry.tarnyagin@stericsson.com
  * License terms: GNU General Public License (GPL) version 2.
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_ser=
ial.c
index 666891a..e56b56c 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
@@ -21,7 +21,7 @@
 #include <linux/debugfs.h>
=20
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Sjur Brendeland<sjur.brandeland@stericsson.com>");
+MODULE_AUTHOR("Sjur Brendeland");
 MODULE_DESCRIPTION("CAIF serial device TTY line discipline");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_LDISC(N_CAIF);
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index b71ce9b..c2cb852 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
  * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
  * License terms: GNU General Public License (GPL) version 2.
  */
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_=
spi_slave.c
index e139e13..98f0366 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
  * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
  * License terms: GNU General Public License (GPL) version 2.
  */
diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index ef2dd94..028b754 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/caif_device.h b/include/net/caif/caif_dev=
ice.h
index d02f044..d6e3c42 100644
--- a/include/net/caif/caif_device.h
+++ b/include/net/caif/caif_device.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index bcb9cc3..4795e81 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
  * Author:  Daniel Martensson / daniel.martensson@stericsson.com
  *	    Dmitry.Tarnyagin  / dmitry.tarnyagin@stericsson.com
  * License terms: GNU General Public License (GPL) version 2
diff --git a/include/net/caif/caif_layer.h b/include/net/caif/caif_laye=
r.h
index 0f3a391..94e5ed6 100644
--- a/include/net/caif/caif_layer.h
+++ b/include/net/caif/caif_layer.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index 90b4ff8..70bfd01 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index 9e5425b..f2ae33d 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cffrml.h b/include/net/caif/cffrml.h
index afac1a4..a06e33f 100644
--- a/include/net/caif/cffrml.h
+++ b/include/net/caif/cffrml.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfmuxl.h b/include/net/caif/cfmuxl.h
index 5847a19..7529995 100644
--- a/include/net/caif/cfmuxl.h
+++ b/include/net/caif/cfmuxl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
index 83a89ba..1c1ad46 100644
--- a/include/net/caif/cfpkt.h
+++ b/include/net/caif/cfpkt.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfserl.h b/include/net/caif/cfserl.h
index f121299..b5b020f 100644
--- a/include/net/caif/cfserl.h
+++ b/include/net/caif/cfserl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index 0f59052..cd47705 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/uapi/linux/caif/caif_socket.h b/include/uapi/linux=
/caif/caif_socket.h
index 3f3bac6..586e9f9 100644
--- a/include/uapi/linux/caif/caif_socket.h
+++ b/include/uapi/linux/caif/caif_socket.h
@@ -1,7 +1,7 @@
 /* linux/caif_socket.h
  * CAIF Definitions for CAIF socket and network layer
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	 Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * Author:	 Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/include/uapi/linux/caif/if_caif.h b/include/uapi/linux/cai=
f/if_caif.h
index 5e7eed4..7618aab 100644
--- a/include/uapi/linux/caif/if_caif.h
+++ b/include/uapi/linux/caif/if_caif.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index df6d56d..1f9ece1 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -1,7 +1,7 @@
 /*
  * CAIF Interface registration.
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  *
  * Borrowed heavily from file: pn_dev.c. Thanks to Remi Denis-Courmont
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 630b8be..05a41c7 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index d76278d..942e00a 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -1,7 +1,7 @@
 /*
  * CAIF USB handler
  * Copyright (C) ST-Ericsson AB 2011
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  *
  */
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 246ac3a..fa39fc2 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 9cd057c..2bd4b58 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 2914659..7aae0b5 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index a63f4a5..3bdddb3 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 204c5e2..8bc7caa 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -2,7 +2,7 @@
  * CAIF Framing Layer.
  *
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 154d9f8..8c5d638 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index e8f9c14..6493351 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index db51830..61d7617 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 147c232..ce60f06 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 95f7f5e..353f793 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 86d2dad..1728fa4 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 910ab06..2622245 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index a8e2a2d..b3b110e 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Author:	Sjur Brendeland
  * License terms: GNU General Public License (GPL) version 2
  */
=20
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 26a4e4e..89586c0 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) ST-Ericsson AB 2010
- * Authors:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * Authors:	Sjur Brendeland
  *		Daniel Martensson / Daniel.Martensson@stericsson.com
  * License terms: GNU General Public License (GPL) version 2
  */
--=20
1.7.5.4
