From: Injong Rhee <rhee@eos.ncsu.edu>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 12:41:50 -0500
Message-ID: <d30ac46c6f4874b149313d5dc17d2a67@eos.ncsu.edu>
References: <20070212191101.GP25760@galon.ev-en.org> <20070212.122058.63127043.davem@davemloft.net> <20070212221241.GQ25760@galon.ev-en.org> <20070212.145351.35661569.davem@davemloft.net> <20070213095613.GR25760@galon.ev-en.org>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.southeast.rr.com ([24.25.9.102]:50682 "EHLO
	ms-smtp-03.southeast.rr.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbXBMRnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 12:43:31 -0500
In-Reply-To: <20070213095613.GR25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 13, 2007, at 4:56 AM, Baruch Even wrote:

>
> According to claims of Doug Leith the cubic algorithm that is in the
> kernel is different from what was proposed and tested. That's an
> important issue which is deflected by personal attacks.

It is not the algorithm "untested" -- it is the implementation not
fully tested. This is exactly the reason we are proposing to build a 
common, convenient,
accessible testbed equipped with a full set of automated testing 
scenarios. This
would be useful to crack out these bugs. There could be a weakness in 
an algorithm, but
there is no bug in the algorithm.

>
> My main gripe is that there is a run to make an untested algorithm the
> default for all Linux installations. And saying that I should test it 
> is
> not an escape route, if it's untested it shouldn't be made the default
> algorithm.
>
> My skimming of the PFLDNet 2007 proceedings showed only the works by
> Injong and Doug on Cubic and Injong tested some version on Linux
> 2.6.13(!) which might noe be the version in the current tree. Doug 
> shows
> some weaknesses of the Cubic algorithm as implemented in Linux.\

That version we tested is patched w/ our implementation of CUBIC. You 
can get
the patch from our site so it is a correct implemenation.
The linux implementation is ever evolving and it is
hard to keep track of everything at an instance. So we are using our 
own version
for our paper publishing. But we also test existing versions of Linux 
implementation.
The version that D. Leith has tested is a version that fixes the 
earlier bug.
Note that having bugs in the implementation does not warrant attacks on
the algorithm itself.

Some "weakness" of CUBIC.. please read my rebuttal
on that paper in my website:  http://www.csc.ncsu.edu/faculty/rhee/
The slow convergence issue of CUBIC has been inherent
feature of CUBIC -- that is a design tradeoff we make when we design
BIC and CUBIC. Depending on the testing environment, CUBIC has
very fast convergence, but only in a very low statistical multiplexing 
environment,
the conversion is slow. WE HAVE ADMITTED THAT SIN.
  So he did not exactly FIND that problem. Also on  the
other issues he just raised..just please read that rebuttal.

I am just sick and tired of hearing all these nonsenses that people 
spray based on some
incidental observation on the behavior of protocols without proper 
comparison
and reasoning why a protocol could behave in that environment being 
tested.


>
> Do you still think that making Cubic the default is a good idea?

Do you think H-TCP could make a good candidate? I remember there are 
bugs in
H-TCP implementation (which went on unnoticed for a long time) -- Leith 
claims
his team found the bugs -- but it seems a little of coincidence that 
after we post
our report on a strange behavior on H-TCP, D. Leith came back saying 
they
found the bugs (no attribution..hmm). We also found some problem
in the weakness of H-TCP algorithm
(not implementation) as well (please read our Convex ordering
paper in PFLDnet07). Based on the same argument of yours, then H-TCP
does not make the cut. I guess none of TCP protocols would have made 
the cut
either.


>
> Baruch
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

