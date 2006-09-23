From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 4/10] bonding: Remove unneeded NULL test
Date: Fri, 22 Sep 2006 21:53:25 -0700
Message-ID: <200609230453.k8N4rPZt028238@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:58326 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750978AbWIWEx0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:53:26 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4rQGl012417
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:53:26 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4rQpI265410
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4rP4I001571
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:26 -0600
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

