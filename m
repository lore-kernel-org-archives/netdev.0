From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.28 0/3] bonding: two fixes and one small regression
Date: Thu, 30 Oct 2008 17:41:13 -0700
Message-ID: <1225413676-13579-1-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37557 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbYJaAlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:41:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9V0f4vX009092
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:04 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9V0fIAx111712
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9V0fHXU014900
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:17 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Three patches for bonding; these apply to net-2.6.

	Patch 1 replaces an increment of the link failure count that was
left out during the mii monitor refactor a few months ago.

	Patch 2 reworks the resource free logic to fix leaks of workqueues
and multicast lists.

	Patch 3 fixes a panic in alb/tlb mode when removing a bond under
various circumstances (when the bond is down, for example).

	Please apply for 2.6.28.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
