From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/7] bonding: Format fix in seq_printf call
Date: Fri, 01 Sep 2006 15:09:35 -0700
Message-ID: <200609012209.k81M9ZZt006089@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:18072 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751058AbWIAWJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:09:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k81M9bOn004171
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:09:37 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k81M9bvi282164
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:09:37 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k81M9ajo030408
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:09:36 -0400
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

-- 
VGER BF report: U 0.498925
