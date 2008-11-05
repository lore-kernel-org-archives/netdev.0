From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/3] bonding: One fix two features
Date: Tue,  4 Nov 2008 17:51:13 -0800
Message-ID: <1225849876-8930-1-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41646 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966AbYKEBvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 20:51:20 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA51lfwn028068
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:47:41 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA51pJWq035514
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:19 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA51pIiJ019831
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Three patches for bonding:

	Patch 1 adds IPv6 gratuitous neighbor advertisements during
failover.

	Patch 2 fixes ALB mode to correctly balance traffic on VLANs
configured above bonding.

	Patch 3 adds alternate aggregator selection policies to 802.3ad
mode.  The new policies permit gang failover within 802.3ad, providing a
means to always have the "best" aggregator be the active aggregator
(instead of waiting until all members of the active aggregator fail, as is
the case currently).

	Please apply for net-next-2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
