From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/7] bonding: miscellaneous fixes
Date: Tue, 29 Jan 2008 18:07:42 -0800
Message-ID: <12016588691476-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:49463 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbYA3CHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:07:51 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U27psc018461
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 21:07:51 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27pQT113540
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:51 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27o8v015742
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Following are 7 bonding related patches:

	patch 1: Revamp parameter parsing again to handle all cases (missed
an edge case last time).

	patch 2: fix set_multicast_list locking issues

	patch 3: Fix possible NULL pointer deref at module init time

	patch 4: Fix race that causes invalid statistics

	patch 5: Don't acquire rtnl in ARP monitor; it's not needed

	patch 6: update version

	patch 7: update MAINTAINERS

	Patches are against the current netdev-2.6#upstream branch.

	Please apply.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
