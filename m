From: David Miller <davem@davemloft.net>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 22:47:49 -0800 (PST)
Message-ID: <20080110.224749.66236050.davem@davemloft.net>
References: <477BD374.6060506@zytor.com>
	<20080110.221615.188955433.davem@davemloft.net>
	<200801110123.38406.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, netdev@vger.kernel.org, klibc@zytor.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbYAKGrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:47:49 -0500
In-Reply-To: <200801110123.38406.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 11 Jan 2008 01:23:37 -0500

> On Friday 11 January 2008, David Miller wrote:
> > From: "H. Peter Anvin" <hpa@zytor.com>
> > > Seems the most logical thing to do would be to break out the small
> > > portion that everyone wants into <linux/sockaddr.h> or somesuch, and
> > > then remove those ifdefs entirely.
> > >
> > > Proposed patch (still being tested) attached...
> >
> > I think this would clearly break existing glibc builds.
> >
> > I agree with fixing the ifdef checks, but not like this.
> 
> how ?  the large crap in linux/socket.h never made it into glibc builds, and 
> the few things at the top which were relocated to linux/sockaddr.h are still 
> pulled in via linux/socket.h.  for glibc, the resulting '#include 
> <linux/socket.h>' should be unchanged.

Hmmm...

Doesn't glibc include linux/socket.h?  If so, before it wouldn't get
the sa_family_t et al. defines (because __GLIBC__ will be defined and
it will be >= 2), but with your change it get those things.

Correct me if I'm wrong.

Thanks.
