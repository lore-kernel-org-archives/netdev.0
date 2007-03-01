From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Thu, 01 Mar 2007 09:05:26 -0800
Message-ID: <200703011705.l21H5Q22005750@death.nxdomain.ibm.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57601 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965410AbXCARFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 12:05:37 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l21H5VXF027825
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 12:05:31 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l21H5VKP282320
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 12:05:31 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l21H5Uqx024365
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 12:05:31 -0500
In-reply-to: <20070301164918.GA3199@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Wed, Feb 28, 2007 at 05:03:37PM -0800, Jay Vosburgh wrote:
[...]
>My only concern is that this code assumes all mcast addresses stored in
>dev->mc-list list are for ipv4 igmp mcast addresses and nothing was done
>for ipv6.
>
>But this is much better than what we have now, so... 

	Agreed, but there's no IPv6 support anywhere in bonding at
present (for unicast or multicast), so this isn't really a loss.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

