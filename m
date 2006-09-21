From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/3] bonding: 3 fixes
Date: Thu, 21 Sep 2006 15:46:30 -0700
Message-ID: <200609212246.k8LMkUZt031618@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45729 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751692AbWIUWqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 18:46:36 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8LMkYSo018675
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 18:46:34 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8LMkWfG294618
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 18:46:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8LMkWe0007716
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 18:46:32 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Patch 1: Validate probe replies in ARP monitor
	Patch 2: Don't mangle LACPDUs
	Patch 3: Fix primary selection error at enslavement time

	These patches are against netdev-2.6#upstream with the set of 7
bonding patches from 1 September 2006 already applied.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
