From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: update docs to correctly reflect arp_ip_target behavior
Date: Wed, 22 Oct 2008 13:30:25 -0700
Message-ID: <1473.1224707425@death.nxdomain.ibm.com>
References: <20081022200639.GA10873@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51571 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357AbYJVUaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 16:30:30 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9MKUSaa006573
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 16:30:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9MKUSkg128438
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 16:30:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9MKUPqY029585
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 16:30:25 -0400
In-reply-to: <20081022200639.GA10873@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>The latest version of Red Hat Enterprise Linux 5 doesn't need '+' in
>front of each IP address listed as an arp_ip_target, and correctly
>supports a comma separated list of IP addresses using the current
>version of initscripts.  This patch drops all references to the need for
>a '+' before each IP address and the description now matches the
>behavior.

	Don't the prior versions of RHEL 5 (initscripts, really) still
need the "+"?  If so, I'd prefer to have this say "for initscripts
versions X - Y (RHEL A.B, Fedora Q.Y), do it this way; for versions
since Y (RHEL A.C, Fedora Q.Z), do it this other way."

	I'm not keen on removing information that isn't tied directly to
the bonding driver itself.  I just know somebody will run the latest
mainline kernel on their RHEL 5.mumble and then the documentation will
steer them down the wrong road.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
