From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/3] bonding: TLB / ALB changes
Date: Tue, 29 Sep 2009 17:15:28 -0700
Message-ID: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34770 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbZI3APd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 20:15:33 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8U08LeN012928
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:08:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8U0Fb3X206006
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8U0FaCw023029
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Note that this patchset is against net-next-2.6 with these
patches from Jiri Pirko already applied:

http://patchwork.ozlabs.org/patch/32684/
http://patchwork.ozlabs.org/patch/34272/

	Three patches for bonding:

	Patch 1 changes the tlb/alb algorithm to try and keep hosts
assigned to the same slave during a rebalance.

	Patch 2 synchronizes the rx and tx hash tables, and unifies
their locking.  Periodic rlb rebalance no longer occurs, as both hash
tables are controlled by the transmit side.

	Patch 3 arranges for ARP packets to be sent on a slave that is
appropriate for the destination, instead of always using the same slave
for all ARP traffic.

	A fourth patch has been discussed on the list (to dump the alb
and tlb hash tables); that patch is not being submitted at this time,
and may return in a different form at some point in the future.

	Please apply for net-next-2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
