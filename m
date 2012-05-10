From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/3] staging: wean rtl8712 off of its ancient duplicate of ip.h
Date: Wed,  9 May 2012 23:47:20 -0400
Message-ID: <1336621641-15467-3-git-send-email-paul.gortmaker@windriver.com>
References: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Cc: florian.c.schilhabel@googlemail.com, ali@internetdog.org,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63204 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab2EJDsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 23:48:11 -0400
In-Reply-To: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver should not be carrying around ancient copies of
headers like <linux/ip.h> for its own use.  Mapping it onto
the mainline one uncovers no build issues.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/staging/rtl8712/ip.h           |  137 --------------------------------
 drivers/staging/rtl8712/rtl8712_recv.c |    2 +-
 drivers/staging/rtl8712/rtl871x_recv.c |    2 +-
 drivers/staging/rtl8712/xmit_linux.c   |    3 +-
 4 files changed, 3 insertions(+), 141 deletions(-)
 delete mode 100644 drivers/staging/rtl8712/ip.h

diff --git a/drivers/staging/rtl8712/ip.h b/drivers/staging/rtl8712/ip.h
deleted file mode 100644
index f37b0f8..0000000
diff --git a/drivers/staging/rtl8712/rtl8712_recv.c b/drivers/staging/rtl8712/rtl8712_recv.c
index b2a7714..e975d0a 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.c
+++ b/drivers/staging/rtl8712/rtl8712_recv.c
@@ -29,12 +29,12 @@
 #define _RTL8712_RECV_C_
 
 #include <linux/if_ether.h>
+#include <linux/ip.h>
 
 #include "osdep_service.h"
 #include "drv_types.h"
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
-#include "ip.h"
 #include "ethernet.h"
 #include "usb_ops.h"
 #include "wifi.h"
diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
index 7376abb..c9d1743 100644
--- a/drivers/staging/rtl8712/rtl871x_recv.c
+++ b/drivers/staging/rtl8712/rtl871x_recv.c
@@ -28,6 +28,7 @@
 
 #define _RTL871X_RECV_C_
 
+#include <linux/ip.h>
 #include <linux/slab.h>
 #include <linux/if_ether.h>
 #include <linux/kmemleak.h>
@@ -36,7 +37,6 @@
 #include "drv_types.h"
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
-#include "ip.h"
 #include "ethernet.h"
 #include "usb_ops.h"
 #include "wifi.h"
diff --git a/drivers/staging/rtl8712/xmit_linux.c b/drivers/staging/rtl8712/xmit_linux.c
index d27f652..c6943c5 100644
--- a/drivers/staging/rtl8712/xmit_linux.c
+++ b/drivers/staging/rtl8712/xmit_linux.c
@@ -29,13 +29,12 @@
 #define _XMIT_OSDEP_C_
 
 #include <linux/usb.h>
+#include <linux/ip.h>
 #include <linux/if_ether.h>
 
 #include "osdep_service.h"
 #include "drv_types.h"
 
-
-#include "ip.h"
 #include "rtl871x_byteorder.h"
 #include "wifi.h"
 #include "mlme_osdep.h"
-- 
1.7.9.1
