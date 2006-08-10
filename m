From: Dave Jones <davej@redhat.com>
Subject: remove unnecessary config.h includes from net/
Date: Wed, 9 Aug 2006 22:21:16 -0400
Message-ID: <20060810022116.GB23634@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26347 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030527AbWHJCVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 22:21:31 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k7A2LUL2011627
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 22:21:30 -0400
Received: from nwo.kernelslacker.org (vpn-248-3.boston.redhat.com [10.13.248.3])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k7A2LQX2029850
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 22:21:29 -0400
Received: from nwo.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by nwo.kernelslacker.org (8.13.7/8.13.5) with ESMTP id k7A2LKtM028228
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 22:21:20 -0400
Received: (from davej@localhost)
	by nwo.kernelslacker.org (8.13.7/8.13.7/Submit) id k7A2LGHj028227
	for netdev@vger.kernel.org; Wed, 9 Aug 2006 22:21:16 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

config.h is automatically included by kbuild these days.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6/net/ipv4/netfilter/ip_conntrack_sip.c~	2006-08-09 22:18:48.000000000 -0400
+++ linux-2.6/net/ipv4/netfilter/ip_conntrack_sip.c	2006-08-09 22:18:53.000000000 -0400
@@ -8,7 +8,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
 #include <linux/module.h>
 #include <linux/ctype.h>
 #include <linux/skbuff.h>
--- linux-2.6/net/ipv4/af_inet.c~	2006-08-09 22:18:58.000000000 -0400
+++ linux-2.6/net/ipv4/af_inet.c	2006-08-09 22:19:03.000000000 -0400
@@ -67,7 +67,6 @@
  *		2 of the License, or (at your option) any later version.
  */
 
-#include <linux/config.h>
 #include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/types.h>
--- linux-2.6/net/ipv4/ipconfig.c~	2006-08-09 22:19:07.000000000 -0400
+++ linux-2.6/net/ipv4/ipconfig.c	2006-08-09 22:19:10.000000000 -0400
@@ -31,7 +31,6 @@
  *              --  Josef Siemes <jsiemes@web.de>, Aug 2002
  */
 
-#include <linux/config.h>
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
--- linux-2.6/net/ipv4/raw.c~	2006-08-09 22:19:14.000000000 -0400
+++ linux-2.6/net/ipv4/raw.c	2006-08-09 22:19:18.000000000 -0400
@@ -38,8 +38,7 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  */
- 
-#include <linux/config.h> 
+
 #include <linux/types.h>
 #include <asm/atomic.h>
 #include <asm/byteorder.h>
--- linux-2.6/net/ipv4/tcp_veno.c~	2006-08-09 22:19:23.000000000 -0400
+++ linux-2.6/net/ipv4/tcp_veno.c	2006-08-09 22:19:26.000000000 -0400
@@ -9,7 +9,6 @@
  * 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
  */
 
-#include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
--- linux-2.6/net/ipv4/tcp_lp.c~	2006-08-09 22:19:31.000000000 -0400
+++ linux-2.6/net/ipv4/tcp_lp.c	2006-08-09 22:19:34.000000000 -0400
@@ -31,7 +31,6 @@
  * Version: $Id: tcp_lp.c,v 1.22 2006-05-02 18:18:19 hswong3i Exp $
  */
 
-#include <linux/config.h>
 #include <linux/module.h>
 #include <net/tcp.h>
 
--- linux-2.6/net/atm/atm_sysfs.c~	2006-08-09 22:19:38.000000000 -0400
+++ linux-2.6/net/atm/atm_sysfs.c	2006-08-09 22:19:40.000000000 -0400
@@ -1,6 +1,5 @@
 /* ATM driver model support. */
 
-#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/kobject.h>
--- linux-2.6/net/core/wireless.c~	2006-08-09 22:19:44.000000000 -0400
+++ linux-2.6/net/core/wireless.c	2006-08-09 22:19:47.000000000 -0400
@@ -72,7 +72,6 @@
 
 /***************************** INCLUDES *****************************/
 
-#include <linux/config.h>		/* Not needed ??? */
 #include <linux/module.h>
 #include <linux/types.h>		/* off_t */
 #include <linux/netdevice.h>		/* struct ifreq, dev_get_by_name() */
--- linux-2.6/net/core/dev_mcast.c~	2006-08-09 22:19:52.000000000 -0400
+++ linux-2.6/net/core/dev_mcast.c	2006-08-09 22:19:59.000000000 -0400
@@ -21,8 +21,7 @@
  *	2 of the License, or (at your option) any later version.
  */
 
-#include <linux/config.h> 
-#include <linux/module.h> 
+#include <linux/module.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <linux/bitops.h>

-- 
http://www.codemonkey.org.uk
