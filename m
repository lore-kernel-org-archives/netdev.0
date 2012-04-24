From: Flavio Leitner <fbl@redhat.com>
Subject: Re: restoring IP multicast addresses when restarting the interface.
Date: Tue, 24 Apr 2012 19:19:34 -0300
Message-ID: <20120424191934.37755018@asterix.rh>
References: <20120420212533.78903e3a@asterix.rh>
	<20120423121425.GA29883@gondor.apana.org.au>
	<20120424153023.0913956e@asterix.rh>
	<20120424.170004.1811627706738841106.davem@davemloft.net>
	<OFB8B0B17A.86602877-ON882579EA.00741868-882579EA.0075F72B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34102 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757146Ab2DXWTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 18:19:49 -0400
In-Reply-To: <OFB8B0B17A.86602877-ON882579EA.00741868-882579EA.0075F72B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Apr 2012 14:28:33 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> netdev-owner@vger.kernel.org wrote on 04/24/2012 02:00:04 PM:
> 
> > From: David Miller <davem@davemloft.net>
> 
> > >> I don't see why they should disappear when the interface goes
> > >> down and then comes back up since these ultimately come from
> > >> application sockets which continue to exist after a down/up.
> > > 
> > > Yeah, but that's not how things used to work before, so my
> > > question is if the kernel should be responsible for keeping
> > > the subscription or the application.
> > > 
> > > If the admin puts down the interface and remove the module,
> > > for instance, then the multicast subscription is gone.
> > > Should the application monitor for that then?
> > > 
> > > David? Any thoughts?
> > 
> > David Stevens at IBM and Herbert at the current multicast
> > experts, so I will defer to them.
> 
> I think restoring the hardware multicast filter on device up
> is useful, desirable and not a bug. :-)

Alright, thanks everyone!
fbl
