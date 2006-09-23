From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 0/10] bonding: Various fixes big and small
Date: Fri, 22 Sep 2006 21:51:54 -0700
Message-ID: <200609230451.k8N4psZt027400@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:28317 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750960AbWIWEv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:51:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4pu6O030721
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:51:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4puca237928
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:51:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4puLJ013102
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:51:56 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Reposting all outstanding bonding patches (a first set of 7, and
a recent set of 3), all against netdev-2.6#upstream.  Some of the
originals had whitespace problems that make git-apply reject them (and,
alas, cg-patch calls regular patch, not git-apply).


	Patch 1: Allow bonding to enslave a 10 Gig adapter without errors
	Patch 2: Convert delay value from s16 to int
	Patch 3: Format fix in seq_printf call
	Patch 4: Remove unneeded NULL test
	Patch 5: Handle large hard_header_len
	Patch 6: Add priv_flag to avoid event mishandling
	Patch 7: Don't release slaves when master is admin down
	Patch 8: Validate probe replies in ARP monitor
	Patch 9: Don't mangle LACPDUs
	Patch 10: Fix primary selection error at enslavement time

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
