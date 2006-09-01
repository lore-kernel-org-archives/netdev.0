From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/7] bonding: Remove unneeded NULL test
Date: Fri, 01 Sep 2006 15:10:02 -0700
Message-ID: <200609012210.k81MA2Zt006335@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:22952 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751068AbWIAWKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:10:04 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k81MA3oJ017727
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:10:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k81MA38o250572
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:10:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k81MA2u1031538
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:10:03 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove unneeded test for NULL.  Reported by Thomas Dillig
<tdillig@stanford.edu> and Isil Dillig <isil@stanford.edu> via Stephen
Hemminger <shemminger@osdl.org>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


--- netdev-2.6.git-upstream/drivers/net/bonding/bond_sysfs.c	2006/08/19 10:22:17	1.1
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_sysfs.c	2006/08/19 15:01:09	1.2
@@ -1093,7 +1093,7 @@
 			     strlen(slave->dev->name)) == 0) {
         			old_active = bond->curr_active_slave;
         			new_active = slave;
-        			if (new_active && (new_active == old_active)) {
+        			if (new_active == old_active) {
 					/* do nothing */
 					printk(KERN_INFO DRV_NAME
 				       	       ": %s: %s is already the current active slave.\n",

-- 
VGER BF report: H 0.139804
