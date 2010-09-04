From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 20/21] ibmveth: Remove some unnecessary include files
Date: Fri, 03 Sep 2010 23:29:47 -0500
Message-ID: <20100904042947.2655.51766.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:57038 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab0IDEaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 00:30:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844BsvG003154
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:11:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844UGJW098292
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 00:30:16 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844UFDp004446
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:30:16 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These files probably came across from the skeleton driver. Remove them.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:29.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:29.000000000 -0500
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
@@ -48,7 +46,6 @@
 #include <asm/atomic.h>
 #include <asm/vio.h>
 #include <asm/iommu.h>
-#include <asm/uaccess.h>
 #include <asm/firmware.h>
 
 #include "ibmveth.h"
