From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V6 0/9] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 24 Sep 2007 17:27:44 +0200
Message-ID: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:59896 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754662AbXIXP1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 11:27:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is the sixth version (see below link to V5) of the 
suggested changes to the bonding driver so it would be able to support 
non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode. 

Patches 1-8 were originally submitted in V5 and patch 9 is an addition by Jay.


Major changes from the previous version:
----------------------------------------

1. Remove the patches to net/core. Bonding will use the NETDEV_GOING_DOWN notification
   instead of NETDEV_CHANGE+IFF_SLAVE_DETACH. This reduces the amount of patches from 11
   to 9.

Links to earlier discussion:
----------------------------

1. A discussion in netdev about bonding support for IPoIB.
http://lists.openwall.net/netdev/2006/11/30/46

2. V5 series
http://lists.openfabrics.org/pipermail/general/2007-September/040996.html

