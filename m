From: Baruch Even <baruch@ev-en.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 20:23:27 +0200
Message-ID: <20070213182327.GT25760@galon.ev-en.org>
References: <20070212191101.GP25760@galon.ev-en.org> <20070212.122058.63127043.davem@davemloft.net> <20070212221241.GQ25760@galon.ev-en.org> <20070212.145351.35661569.davem@davemloft.net> <20070213095613.GR25760@galon.ev-en.org> <d30ac46c6f4874b149313d5dc17d2a67@eos.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Injong Rhee <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:11339
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbXBMSXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 13:23:30 -0500
Content-Disposition: inline
In-Reply-To: <d30ac46c6f4874b149313d5dc17d2a67@eos.ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Injong Rhee <rhee@eos.ncsu.edu> [070213 19:43]:
> 
> On Feb 13, 2007, at 4:56 AM, Baruch Even wrote:
> 
> >
> >According to claims of Doug Leith the cubic algorithm that is in the
> >kernel is different from what was proposed and tested. That's an
> >important issue which is deflected by personal attacks.
> 
> It is not the algorithm "untested" -- it is the implementation not
> fully tested. This is exactly the reason we are proposing to build a common, convenient,
> accessible testbed equipped with a full set of automated testing scenarios. This
> would be useful to crack out these bugs. There could be a weakness in an algorithm, but
> there is no bug in the algorithm.

Yes. That was bad terminology on my part.

A testbed would be nice, I've heard several times about ideas to do that
but haven't seen anything materialize yet.

> >Do you still think that making Cubic the default is a good idea?
> 
> Do you think H-TCP could make a good candidate? I remember there are bugs in

I don't. And if you'd bother looking back at the thread you'd see that I
didn't even consider that an option. You automatically assume that I'm
only trying to further H-TCP, far from it. I've finished my MSc already
and am back to being a free man with his own thoughts. I've seen what
happened before and want to prevent that from happening again. I think
that the bic algorithm wasn't good enough and the implementation was
even buggier and still it was made the default without much thought and
no one thought to pull it back.

> H-TCP implementation (which went on unnoticed for a long time) -- Leith claims
> his team found the bugs -- but it seems a little of coincidence that after we post
> our report on a strange behavior on H-TCP, D. Leith came back saying they
> found the bugs (no attribution..hmm).

I'm the one who found the issue and I can assure you that I didn't see
any notice from you before I did that. I was simply migrating my work
from an older kernel with our patches to the latest kernel at the time
with the patches as committed by Stephen. There was a difference between
what was submitted by myself and what was committed and it took us time
to detect that for the same reason I'm worried about the existing cubic
implementation, we were using our own patches and not testing the Linux
implementation. This is the same thing that is happening now with cubic.

> We also found some problem in the weakness of H-TCP algorithm (not
> implementation) as well (please read our Convex ordering paper in
> PFLDnet07). Based on the same argument of yours, then H-TCP does not
> make the cut. I guess none of TCP protocols would have made the cut
> either.

Bingo.

Baruch
