From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V5 0/11] net/bonding: ADD IPoIB support for the	bonding driver
Date: Thu, 20 Sep 2007 16:33:06 +0300
Message-ID: <46F27692.3070404@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:11346 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751056AbXITNdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 09:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is the fifth version (see below link to V4) of the 
suggested changes to the bonding driver so it would be able to support 
non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode. 

Patches 1-10 were originally submitted in V4 and patch 11 is an addition by Jay.

Jay,
The bonding patches you acked remain unchanged while I guess I sitll need
to get an official ack by Roland for the IPoIB patches.
Is it OK with you to push the entire series to the networking tree?
Roland has already agreed to do so.


Major changes from the previous version:
----------------------------------------
1. Style changes
2. IPoIB - notify slave detach on vlan delete
3. Add function to net/core for slave detach instead of having it only in
   ib/ipoib
4. IPoIB - handle ib device and bonding device the same way in neigh_cleanup
   function

Links to earlier discussion:
----------------------------

1. A discussion in netdev about bonding support for IPoIB.
http://lists.openwall.net/netdev/2006/11/30/46

2. V4 series
http://lists.openfabrics.org/pipermail/general/2007-August/039825.html

