From: Anton Blanchard <anton@samba.org>
Subject: [patch 19/20] ibmveth: Remove some unnecessary include files
Date: Mon, 23 Aug 2010 10:09:49 +1000
Message-ID: <20100823001240.093607942@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51874 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304Ab0HWAaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:30:04 -0400
Content-Disposition: inline; filename=veth_includes
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These files probably came across from the skeleton driver. Remove them.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 09:23:35.101324676 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 09:23:36.391233048 +1000
@@ -29,14 +29,12 @@
 #include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/ioport.h>
 #include <linux/dma-mapping.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
-#include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/pm.h>
 #include <linux/ethtool.h>
@@ -47,7 +45,6 @@
 #include <asm/atomic.h>
 #include <asm/vio.h>
 #include <asm/iommu.h>
-#include <asm/uaccess.h>
 #include <asm/firmware.h>
 
 #include "ibmveth.h"


