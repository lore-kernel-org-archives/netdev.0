From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC/PATCH][Bonding]: keep slave state when admin down
Date: Thu, 20 Jul 2006 11:50:00 -0700
Message-ID: <200607201850.k6KIo0hg016751@death.nxdomain.ibm.com>
References: <1153401556.5098.43.camel@jzny2>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:28368 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964787AbWGTSuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 14:50:06 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6KIo2Zg026018
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 20 Jul 2006 14:50:04 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6KIo21h275114
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 20 Jul 2006 14:50:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6KIo2jm013299
	for <netdev@vger.kernel.org>; Thu, 20 Jul 2006 14:50:02 -0400
To: hadi@cyberus.ca
In-reply-to: <1153401556.5098.43.camel@jzny2> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:

>When a bonding netdevice is admin-ed down it looses the slaves
>attributes (set via ifenslave). This is not consistent with other
>behavior of netdevices (example a qdisc attached to a netdevice doesnt
>disappear or an attached IP address etc).
>The included patch fixes this. Ive tested by ifenslaving, downing the
>bond, checking /proc and making sure it still has the slaves, up-ing the
>bond and making sure things continue to work.

	Do the initscript and sysconfig packages (/sbin/ifup, ifdown,
that stuff in /etc/sysconfig/network-scripts, etc) do the right thing
with this change?

	If memory serves, the initscripts will down the bond during
setup; I'm not sure if there is any dependency on that action releasing
all (possibly preexisting) slaves.

	I don't have a big problem with this, but I'm a little concerned
that there may be dependencies on the existing behavior.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
