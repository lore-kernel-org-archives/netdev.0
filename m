From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6 0/4] bonding: Four patches
Date: Fri, 28 Aug 2009 14:57:48 -0700
Message-ID: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44519 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbZH1V5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 17:57:55 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SLmXGC022259
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:48:33 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SLvrmM218832
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:53 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SLvreC011580
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:53 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Four patches for bonding:

	Patch 1 adds the propogation of vlan_features from the slaves
to the master device.

	Patch 2 replaces a cumbersome manual MAC address comparison with
compare_ether_addr.

	Patch 3 removes a useless test against INT_MAX.

	Patch 4 modifies bond_check_dev_link to handle devices that leave
carrier up even when adminstratively down.

	Due to lab machine adventures on my end, I was only able to compile
test patches 2 - 4.

	Please apply for net-next-2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
