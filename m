From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 3/10] bonding: Format fix in seq_printf call
Date: Fri, 22 Sep 2006 21:53:08 -0700
Message-ID: <200609230453.k8N4r8Zt028079@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:11233 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750974AbWIWExK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:53:10 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4rApx002757
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:53:10 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4r9QB235794
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:09 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4r91q007900
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:53:09 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



From: Kenzo Iwami <k-iwami@cj.jp.nec.com>

Though link_failure_count is type unsigned int, this value is outputted to
/proc/net/bonding/bondX file using "%d" instead of "%u".

The attached patch fixes this problem.

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>



--- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 10:39:34	1.2
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 14:46:07	1.3
@@ -2951,7 +2951,7 @@
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
-	seq_printf(seq, "Link Failure Count: %d\n",
+	seq_printf(seq, "Link Failure Count: %u\n",
 		   slave->link_failure_count);
 
 	seq_printf(seq,

