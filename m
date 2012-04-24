From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: restoring IP multicast addresses when restarting the interface.
Date: Tue, 24 Apr 2012 14:28:33 -0700
Message-ID: <OFB8B0B17A.86602877-ON882579EA.00741868-882579EA.0075F72B@us.ibm.com>
References: <20120420212533.78903e3a@asterix.rh>	<20120423121425.GA29883@gondor.apana.org.au>
	<20120424153023.0913956e@asterix.rh> <20120424.170004.1811627706738841106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: fbl@redhat.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:43480 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757707Ab2DXVay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 17:30:54 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 24 Apr 2012 15:30:53 -0600
In-Reply-To: <20120424.170004.1811627706738841106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/24/2012 02:00:04 PM:

> From: David Miller <davem@davemloft.net>

> >> I don't see why they should disappear when the interface goes
> >> down and then comes back up since these ultimately come from
> >> application sockets which continue to exist after a down/up.
> > 
> > Yeah, but that's not how things used to work before, so my
> > question is if the kernel should be responsible for keeping
> > the subscription or the application.
> > 
> > If the admin puts down the interface and remove the module,
> > for instance, then the multicast subscription is gone.
> > Should the application monitor for that then?
> > 
> > David? Any thoughts?
> 
> David Stevens at IBM and Herbert at the current multicast
> experts, so I will defer to them.

I think restoring the hardware multicast filter on device up
is useful, desirable and not a bug. :-)

                                                +-DLS
