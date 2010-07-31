From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 14/29] LMC: Remove now empty header file lmc.h.
Date: Sat, 31 Jul 2010 17:05:37 +0200
Message-ID: <1280588752-9340-14-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52516 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756518Ab0GaPGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:19 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/lmc.h   |    6 ------
 drivers/net/wan/lmc/main.c  |    1 -
 drivers/net/wan/lmc/media.c |    1 -
 3 files changed, 0 insertions(+), 8 deletions(-)
 delete mode 100644 drivers/net/wan/lmc/lmc.h

diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
deleted file mode 100644
index 5f467d1..0000000
--- a/drivers/net/wan/lmc/lmc.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _LMC_H_
-#define _LMC_H_
-
-#include "var.h"
-
-#endif
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index c80131f..eb5b2ea 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -70,7 +70,6 @@
=20
 #define DRIVER_VERSION  ((DRIVER_MAJOR_VERSION << 8) + DRIVER_MINOR_VE=
RSION)
=20
-#include "lmc.h"
 #include "var.h"
 #include "ioctl.h"
=20
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 9b1c394..411138f 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -16,7 +16,6 @@
 #include <linux/uaccess.h>
 #include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
-#include "lmc.h"
 #include "var.h"
 #include "ioctl.h"
=20
--=20
1.7.1.1

