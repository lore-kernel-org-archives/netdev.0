From: Anton Blanchard <anton@samba.org>
Subject: [patch 20/20] ibmveth: Update module information and version
Date: Mon, 23 Aug 2010 10:09:50 +1000
Message-ID: <20100823001240.188932995@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51878 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab0HWAaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:30:14 -0400
Content-Disposition: inline; filename=veth_fix_author
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an entry to the MAINTAINERS file for ibmveth, clean up the copyright
and add all authors. Change the name of the module to reflect the product name
over the last number of years.

Considering all the changes we have made, bump the driver version.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 09:23:36.391233048 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 09:23:37.561149945 +1000
@@ -1,28 +1,27 @@
 /*
- * IBM eServer i/pSeries Virtual Ethernet Device Driver
- * Copyright (C) 2003 IBM Corp.
- *  Originally written by Dave Larson (larson1@us.ibm.com)
- *  Maintained by Santiago Leon (santil@us.ibm.com)
+ * IBM Power Virtual Ethernet Device Driver
  *
- *  This program is free software; you can redistribute it and/or modify
- *  it under the terms of the GNU General Public License as published by
- *  the Free Software Foundation; either version 2 of the License, or
- *  (at your option) any later version.
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
  *
- *  This program is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *  GNU General Public License for more details.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
  *
- *  You should have received a copy of the GNU General Public License
- *  along with this program; if not, write to the Free Software
- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
- *                                                                   USA
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  *
- * This module contains the implementation of a virtual ethernet device
- * for use with IBM i/pSeries LPAR Linux.  It utilizes the logical LAN
- * option of the RS/6000 Platform Architechture to interface with virtual
- * ethernet NICs that are presented to the partition by the hypervisor.
+ * Copyright (C) IBM Corporation, 2003, 2010
+ *
+ * Authors: Dave Larson <larson1@us.ibm.com>
+ *	    Santiago Leon <santil@linux.vnet.ibm.com>
+ *	    Brian King <brking@linux.vnet.ibm.com>
+ *	    Robert Jennings <rcj@linux.vnet.ibm.com>
+ *	    Anton Blanchard <anton@au.ibm.com>
  */
 
 #include <linux/module.h>
@@ -57,12 +56,11 @@ static struct kobj_type ktype_veth_pool;
 
 
 static const char ibmveth_driver_name[] = "ibmveth";
-static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet "
-					    "Driver";
-#define ibmveth_driver_version "1.03"
+static const char ibmveth_driver_string[] = "IBM Power Virtual Ethernet Driver";
+#define ibmveth_driver_version "1.04"
 
 MODULE_AUTHOR("Santiago Leon <santil@us.ibm.com>");
-MODULE_DESCRIPTION("IBM i/pSeries Virtual Ethernet Driver");
+MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ibmveth_driver_version);
 
Index: net-next-2.6/MAINTAINERS
===================================================================
--- net-next-2.6.orig/MAINTAINERS	2010-08-23 09:22:56.514065611 +1000
+++ net-next-2.6/MAINTAINERS	2010-08-23 09:23:37.571149242 +1000
@@ -2849,6 +2849,12 @@ M:	Brian King <brking@us.ibm.com>
 S:	Supported
 F:	drivers/scsi/ipr.*
 
+IBM Power Virtual Ethernet Device Driver
+M:	Santiago Leon <santil@linux.vnet.ibm.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ibmveth.*
+
 IBM ServeRAID RAID DRIVER
 P:	Jack Hammer
 M:	Dave Jeffery <ipslinux@adaptec.com>
Index: net-next-2.6/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.h	2010-08-23 09:22:56.534064193 +1000
+++ net-next-2.6/drivers/net/ibmveth.h	2010-08-23 09:23:37.581148530 +1000
@@ -1,26 +1,28 @@
-/**************************************************************************/
-/*                                                                        */
-/* IBM eServer i/[Series Virtual Ethernet Device Driver                   */
-/* Copyright (C) 2003 IBM Corp.                                           */
-/*  Dave Larson (larson1@us.ibm.com)                                      */
-/*  Santiago Leon (santil@us.ibm.com)                                     */
-/*                                                                        */
-/*  This program is free software; you can redistribute it and/or modify  */
-/*  it under the terms of the GNU General Public License as published by  */
-/*  the Free Software Foundation; either version 2 of the License, or     */
-/*  (at your option) any later version.                                   */
-/*                                                                        */
-/*  This program is distributed in the hope that it will be useful,       */
-/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
-/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
-/*  GNU General Public License for more details.                          */
-/*                                                                        */
-/*  You should have received a copy of the GNU General Public License     */
-/*  along with this program; if not, write to the Free Software           */
-/*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  */
-/*                                                                   USA  */
-/*                                                                        */
-/**************************************************************************/
+/*
+ * IBM Power Virtual Ethernet Device Driver
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2003, 2010
+ *
+ * Authors: Dave Larson <larson1@us.ibm.com>
+ *	    Santiago Leon <santil@linux.vnet.ibm.com>
+ *	    Brian King <brking@linux.vnet.ibm.com>
+ *	    Robert Jennings <rcj@linux.vnet.ibm.com>
+ *	    Anton Blanchard <anton@au.ibm.com>
+ */
 
 #ifndef _IBMVETH_H
 #define _IBMVETH_H


