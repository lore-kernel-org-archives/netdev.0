From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 1 Aug 2006 13:03:35 -0400
Message-ID: <20060801170329.GG29208@tuxdriver.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com> <44CF7E8B.9030407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:62221 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751661AbWHARDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:03:50 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44CF7E8B.9030407@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:17:15AM -0700, Ben Greear wrote:
> John W. Linville wrote:

> Well, if it makes you feel better, I can't see a good way to do
> vlans-over-vlans cleanly, backwards compatibly, and functional with
> bridging, etc.  I would not plan to add such a feature to the kernel
> unless from it's moment of inclusion it could handle at least bridging,
> either.  So that feature will probably not see the light of day
> any time soon :)

I suspected as much. :-)

> >Most (actually all afaik) L2 networking equipment enforces some
> >hierarchy on the relationship between these L2 entities.  I am more
> >and more convinced we should do the same, although I do acknowledge
> >that the current situation does allow for some cleverness.
> 
> Very often, the answer to difficult networking issues is to 'get a linux 
> box', since that very flexibility is often key to interesting problems.
 
No doubt that is true.  FWIW I think we would still have to be very
flexible about when/how/where vlan tagging gets done, if for no other
reason than that I can't seem to convince myself of any one place it
should go... :-)

Oh, and there may be no reason to ever remove the virtual device vlan
implementation, even if there was a nicer/cleaner/better L2 layer
for the other 90+%.

> >I'm just not sure that cleverness is worth the headache, especially
> >since the most clever things usually only work by accident...
> 
> Or, work by solid, modular design and small tweaks!

Point taken.  But stashing little hacks in the networking core for
specific virtual drivers isn't totally modular either.  And even if
it were, "modular design" probably belongs on the list of "things
that can be taken too far", like "everything in userland", "never
use ioctl", and "microkernels are superior". :-)

I definitely respect your contributions both past and (presumably)
future, and I have no doubt that you have seen any number of
'interesting' vlan scenarios.  Again, my complaint is more about
the overall lack of integration/coherence for L2 functions.  I have
few complaints about individual functions (that I wish to discuss in
this thread).

John
-- 
John W. Linville
linville@tuxdriver.com
