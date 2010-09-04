From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 21/21] ibmveth: Update module information and version
Date: Fri, 03 Sep 2010 23:29:53 -0500
Message-ID: <20100904042953.2655.50911.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:49768 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab0IDEaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 00:30:22 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844Fo6E017769
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:15:50 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844UL9r449264
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:30:21 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844UK0B004802
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:21 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an entry to the MAINTAINERS file for ibmveth, clean up the copyright
and add all authors. Change the name of the module to reflect the product name
over the last number of years.

Considering all the changes we have made, bump the driver version.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:31.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:32.000000000 -0500
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
@@ -58,12 +57,11 @@ static struct kobj_type ktype_veth_pool;
 
 
 static const char ibmveth_driver_name[] = "ibmveth";
-static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet "
-					    "Driver";
-#define ibmveth_driver_version "1.03"
+static const char ibmveth_driver_string[] = "IBM Power Virtual Ethernet Driver";
+#define ibmveth_driver_version "1.04"
 
-MODULE_AUTHOR("Santiago Leon <santil@us.ibm.com>");
-MODULE_DESCRIPTION("IBM i/pSeries Virtual Ethernet Driver");
+MODULE_AUTHOR("Santiago Leon <santil@linux.vnet.ibm.com>");
+MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ibmveth_driver_version);
 
Index: net-next-2.6/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.h	2010-09-03 22:19:20.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.h	2010-09-03 22:19:32.000000000 -0500
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
Index: net-next-2.6/MAINTAINERS
===================================================================
--- net-next-2.6.orig//MAINTAINERS	2010-09-03 22:17:03.000000000 -0500
+++ net-next-2.6/MAINTAINERS	2010-09-03 22:19:32.000000000 -0500
@@ -2856,6 +2856,12 @@ M:	Brian King <brking@us.ibm.com>
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
