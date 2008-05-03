From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/4] bonding: bug fixes for 2.6.26
Date: Fri,  2 May 2008 17:49:36 -0700
Message-ID: <12097757801056-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:50442 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765569AbYECAtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:49:47 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430ngpR009458
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:42 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430ngUt258822
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:42 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430ngTW010473
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Following are four bonding bug fixes for 2.6.26, as follows:

	1- Fix error unwind logic in bond_create (call
unregister_netdevice instead of free_netdev).

	2- Fix error unwind in bonding_store_bonds (release necessary
locks).

	3- Fix deadlock between bonding_store_bonds and bond_destroy_sysfs
(do sysfs action outside of rtnl).

	4- Fix error unwind in bond_enslave to correctly clear master
setting and IFF_SLAVE.

	Please apply.  Thanks,

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
