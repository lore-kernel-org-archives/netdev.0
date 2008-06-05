From: Grant Grundler <grundler@parisc-linux.org>
Subject: PATCH 2.6.27 update first comment in tulip files
Date: Thu, 5 Jun 2008 00:38:55 -0600
Message-ID: <20080605063855.GA20609@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:37701 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbYFEGjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 02:39:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three basic changes to the comments at the top of each file:
1) remove stale "Maintained by" line...I prefer people look in MAINTAINERS.
2) Drop reference to stale sf.net/tulip website (I didn't see anything
   of value there)
3) Point people at bugzilla.kernel.org to submit bugs...will always
   get tracked regardless of who the maintainer is.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

---
Jeff,
This is intended for 2.6.27 once the merge window opens.
Patch is actually against 2.6.26-rc4.

thanks,
grant



diff --git a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
index 6c400cc..1210fb3 100644
--- a/drivers/net/tulip/21142.c
+++ b/drivers/net/tulip/21142.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/21142.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,9 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
-
+	for more information on this driver.
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 #include <linux/delay.h>
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index da2206f..0dcced1 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/eeprom.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,9 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
-
+	for more information on this driver.
+	Please submit bug reports to http://bugzilla.kernel.org/.
 */
 
 #include <linux/pci.h>
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 6284afd..c6bad98 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/interrupt.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,8 +8,8 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
+        Please submit bugs to http://bugzilla.kernel.org/ .
 
 */
 
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index b562566..91cf9c8 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/media.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
index be82a2e..d3253ed 100644
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/pnic.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index 4e4a879..f495791 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/pnic2.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
         Modified to hep support PNIC_II by Kevin B. Hendricks
@@ -10,9 +9,9 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+        Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 
diff --git a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
index d2c1f42..a0e0842 100644
--- a/drivers/net/tulip/timer.c
+++ b/drivers/net/tulip/timer.c
@@ -1,7 +1,6 @@
 /*
 	drivers/net/tulip/timer.c
 
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,11 +8,12 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
+
 #include "tulip.h"
 
 
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 92c68a2..19abbc3 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -8,9 +8,9 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 #ifndef __NET_TULIP_H__
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f9d13fa..d42e526 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1,7 +1,5 @@
-/* tulip_core.c: A DEC 21x4x-family ethernet driver for Linux. */
+/*	tulip_core.c: A DEC 21x4x-family ethernet driver for Linux.
 
-/*
-	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
@@ -9,9 +7,9 @@
 	of the GNU General Public License, incorporated herein by reference.
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
-	for more information on this driver, or visit the project
-	Web page at http://sourceforge.net/projects/tulip/
+	for more information on this driver.
 
+	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
 
