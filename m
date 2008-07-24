From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL pointer dereference
Date: Thu, 24 Jul 2008 22:37:06 +0800
Message-ID: <20080724143706.GA8461@gondor.apana.org.au>
References: <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net> <20080724122203.GA7187@gondor.apana.org.au> <84144f020807240540vbe7ef50uee2cacabe8016546@mail.gmail.com> <20080724125004.GA7426@gondor.apana.org.au> <1216905109.15519.200.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Christoph Lameter <cl@linux-foundation.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35028 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750799AbYGXOh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:37:59 -0400
Content-Disposition: inline
In-Reply-To: <1216905109.15519.200.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 08:11:49AM -0500, Matt Mackall wrote:
>
> You don't honestly expect people to correctly code to such a standard,
> do you? People will assume that ksize never fails, they will be wrong,
> and computers will die.

If we follow this argument then most of our interfaces would be
broken.

> >  You're taking
> > away an entire interface just because an underlying implementation
> > that's used by a very small proportion of users doesn't do the
> > right thing.
> 
> Umm, no. There were very few users to being with, so it was actually a
> fairly large proportion. And that suggested the interface was a bad
> idea.

Huh? I'm talking about users of the kernel.  A very small proportion
of those use SLOB.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
