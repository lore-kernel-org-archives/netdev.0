From: Shmuel Hen <shmulik.hen@intel.com>
Subject: Fwd: [bonding] trivial - Update comment blocks and version field
Date: Mon, 5 Jan 2004 17:10:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051710.50622.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



----------  Forwarded Message  ----------

Subject: [bonding] trivial - Update comment blocks and version field
Date: Monday 05 January 2004 16:41
From: Shmuel Hen <shmulik.hen@intel.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
Cc: "Jay Vosburgh" <fubar@us.ibm.com>, "Shmulik Hen" <shmulik.hen@intel.com>, "Amir Noam" <amir.noam@intel.com>, "Noam Marom" <noam.marom@intel.com>

Update comment blocks, version field and copyright years to match all
the recent changes that were accepted into 2.4/2.6.

Applies on top of latest netdev BK tree.

--
Shmulik.

diff -Nuarp a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
--- a/Documentation/networking/ifenslave.c	Mon Jan  5 15:40:57 2004
+++ b/Documentation/networking/ifenslave.c	Mon Jan  5 16:34:13 2004
@@ -89,13 +89,13 @@
  *	   while it is running. It was already set during enslave. To
  *	   simplify things, it is now handeled separately.
  *
- *    - 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ *    - 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	 - Code cleanup and style changes
  *	   set version to 1.1.0
  */
 
 #define APP_VERSION	"1.1.0"
-#define APP_RELDATE	"Septemer 24, 2003"
+#define APP_RELDATE	"December 1, 2003"
 #define APP_NAME	"ifenslave"
 
 static char *version =
diff -Nuarp a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
--- a/drivers/net/bonding/bond_3ad.c	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bond_3ad.c	Mon Jan  5 16:34:13 2004
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
@@ -48,7 +48,7 @@
  *	  problem on very high Tx traffic load where packets may get dropped
  *	  by the slave.
  *
- * 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Code cleanup and style changes
  */
 
diff -Nuarp a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
--- a/drivers/net/bonding/bond_3ad.h	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bond_3ad.h	Mon Jan  5 16:34:13 2004
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
@@ -29,7 +29,7 @@
  *	- Renamed bond_3ad_link_status_changed() to
  *	  bond_3ad_handle_link_change() for compatibility with TLB.
  *
- * 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Code cleanup and style changes
  */
 
diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bond_alb.c	Mon Jan  5 16:34:13 2004
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -29,8 +29,11 @@
  *	- Add support for setting bond's MAC address with special
  *	  handling required for ALB/TLB.
  *
- * 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Code cleanup and style changes
+ *
+ * 2003/12/30 - Amir Noam <amir.noam at intel dot com>
+ *	- Fixed: Cannot remove and re-enslave the original active slave.
  */
 
 //#define BONDING_DEBUG 1
diff -Nuarp a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
--- a/drivers/net/bonding/bond_alb.h	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bond_alb.h	Mon Jan  5 16:34:14 2004
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -25,7 +25,7 @@
  *	- Add support for setting bond's MAC address with special
  *	  handling required for ALB/TLB.
  *
- * 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Code cleanup and style changes
  */
 
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bond_main.c	Mon Jan  5 16:34:14 2004
@@ -452,6 +452,12 @@
  *	  o Change struct member names and types.
  *	  o Chomp trailing spaces, remove empty lines, fix indentations.
  *	  o Re-organize code according to context.
+ *
+ * 2003/12/30 - Amir Noam <amir.noam at intel dot com>
+ *	- Fixed: Cannot remove and re-enslave the original active slave.
+ *	- Fixed: Releasing the original active slave causes mac address duplication.
+ *	- Add support for slaves that use ethtool_ops.
+ *	  Set version to 2.5.3.
  */
 
 //#define BONDING_DEBUG 1
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Mon Jan  5 15:40:57 2004
+++ b/drivers/net/bonding/bonding.h	Mon Jan  5 16:34:14 2004
@@ -23,7 +23,7 @@
  * 2003/05/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Added support for Transmit load balancing mode.
  *
- * 2003/09/24 - Shmulik Hen <shmulik.hen at intel dot com>
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Code cleanup and style changes
  */
 
@@ -36,8 +36,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.5.0"
-#define DRV_RELDATE	"December 1, 2003"
+#define DRV_VERSION	"2.5.3"
+#define DRV_RELDATE	"December 30, 2003"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff -Nuarp a/include/linux/if_bonding.h b/include/linux/if_bonding.h
--- a/include/linux/if_bonding.h	Mon Jan  5 15:40:57 2004
+++ b/include/linux/if_bonding.h	Mon Jan  5 16:34:14 2004
@@ -32,6 +32,9 @@
  * 2003/05/01 - Amir Noam <amir.noam at intel dot com>
  *	- Added ABI version control to restore compatibility between
  *	  new/old ifenslave and new/old bonding.
+ *
+ * 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Code cleanup and style changes
  */
 
 #ifndef _LINUX_IF_BONDING_H
@@ -86,7 +89,7 @@ typedef struct ifbond {
 typedef struct ifslave
 {
 	__s32 slave_id; /* Used as an IN param to the BOND_SLAVE_INFO_QUERY ioctl */
-	__s8 slave_name[IFNAMSIZ];
+	char slave_name[IFNAMSIZ];
 	__s8 link;
 	__s8 state;
 	__u32  link_failure_count;
