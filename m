From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes, bonding update
Date: Thu, 30 May 2013 17:55:38 -0700
Message-ID: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:33326 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424Ab3EaAz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 20:55:58 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 20:55:57 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BE9E338C804A
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:54 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0ttGr312786
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:55:55 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0tsCB011888
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 21:55:54 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patch set includes 6 patches: four fixes to the dev_mc_sync /
dev_mc_unsync system; and two patches to bonding, one to utilize the sync
/ unsync functions, and another minor fix related to MAC address handling.

	A brief description of each patch:

	1. uninitialized variable in __hw_addr_create_ex

	2. __hw_addr_unsync_one does not work because "from" addresses
		aren't marked as "synced."

	3. __hw_addr_sync_one as called by __hw_addr_sync_multiple will
		not remove references properly

	4. dev_mc_sync_multiple doesn't call the _multiple helper function

	5. Convert bonding to use dev_{mc,uc}_sync / unsync

	6. Disallow changes of bonding MAC if fail_over_mac is set to
		"follow".

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
