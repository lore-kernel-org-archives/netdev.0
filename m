From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/5] bonding: Fixes and updates
Date: Fri, 13 Jun 2008 18:11:59 -0700
Message-ID: <12134059242107-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46118 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756273AbYFNBML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:11 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C5eZ007590
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C5dK178946
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C5rW030196
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:05 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Five patches for bonding; these apply to net-next-2.6.

	Patches 1 - 3 comprise support for NETDEV_BONDING_FAILOVER
notifiers; the first patch adds the define, the second cleans up part of
bonding in preparation for the notifier call, and the third adds the
notifier call itself.

	Patch 4 cleans up and improves previously added support for
specifying the number of gratuitous ARPs to be issued at failover time for
the active-backup mode.

	Patch 5 permits specifying max_bonds as zero (creating no bond0
device).  Also provides an API from net/core to create and destroy files
in net_class so that /sys/class/net/bonding_masters will be created.  This
was previously done by backtracking from the first bonding device's sysfs
information (dev->dev.class).

	Please apply.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
