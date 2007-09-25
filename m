From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH V6 0/9] net/bonding: ADD IPoIB support for the bonding driver
Date: Tue, 25 Sep 2007 08:24:29 -0700
Message-ID: <10376.1190733869@death>
References: <46F7D770.4090500@voltaire.com>
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	OpenFabrics General <general@lists.openfabrics.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42833 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416AbXIYPYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 11:24:37 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8PFObds017448
	for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 11:24:37 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PFObnq515640
	for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 11:24:37 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PFOWdQ027776
	for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 11:24:36 -0400
In-reply-to: <46F7D770.4090500@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


ACK patches 3 - 9.

	Roland, are you comfortable with the IB changes in patches 1 and 2?

	Jeff, when Roland acks patches 1 and 2, please apply all 9.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


Moni Shoua <monis@voltaire.com> wrote:

>This patch series is the sixth version (see below link to V5) of the 
>suggested changes to the bonding driver so it would be able to support 
>non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode. 
>
>Patches 1-8 were originally submitted in V5 and patch 9 is an addition by Jay.
>
>
>Major changes from the previous version:
>----------------------------------------
>
>1. Remove the patches to net/core. Bonding will use the NETDEV_GOING_DOWN notification
>   instead of NETDEV_CHANGE+IFF_SLAVE_DETACH. This reduces the amount of patches from 11
>   to 9.
>
>Links to earlier discussion:
>----------------------------
>
>1. A discussion in netdev about bonding support for IPoIB.
>http://lists.openwall.net/netdev/2006/11/30/46
>
>2. V5 series
>http://lists.openfabrics.org/pipermail/general/2007-September/040996.html
>
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
