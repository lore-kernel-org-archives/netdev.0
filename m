From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: 23 Jun 2007 23:22:38 +0200
Message-ID: <m3wsxu1i3l.fsf@ursa.amorsen.dk>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com> <20070623.135737.22037347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42131 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbXFWVXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 17:23:05 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I2D4J-0006ui-Bf
	for netdev@vger.kernel.org; Sat, 23 Jun 2007 23:22:55 +0200
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 23:22:55 +0200
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2007 23:22:55 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "DM" == David Miller <davem@davemloft.net> writes:

DM> To be honest I think this form of virtualization is a complete
DM> waste of time, even the openvz approach.

You are only considering the security values of OpenVZ. Where I work,
OpenVZ and Linux-vserver are used for their ability to cleanly
separate processes. Security-wise, we could get the same effect just
by running the processes as separate users, but management-wise it is
so much easier to give them a completely separate environment.
OpenVZ's network virtualization enables us to do things which are
completely impossible with both the vanilla kernel and Xen -- e.g.
hundreds of virtual routers, with their own routing daemons.

Policy routing just doesn't cut it; it's cumbersome to set up, limited
to 256 tables, and routing daemons generally can't handle it well, if
at all.


/Benny



