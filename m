From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bug in random32.c: all-zero outputs with probability 1/2^32,
 other seeding bugs
Date: Wed, 2 Jul 2008 09:40:10 -0700
Message-ID: <20080702094010.10232256@extreme>
References: <20080619153045.GC1455@randombit.net>
	<20080701231927.GW7647@pirzuine>
	<20080701173405.cb28db84.akpm@linux-foundation.org>
	<1214968951.11311.122.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Benoit Boissinot <bboissin@gmail.com>,
	linux-kernel@vger.kernel.org, lloyd@randombit.net,
	"Theodore Ts'o" <tytso@mit.edu>, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826AbYGBQkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 12:40:18 -0400
In-Reply-To: <1214968951.11311.122.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Jul 2008 22:22:31 -0500
Matt Mackall <mpm@selenic.com> wrote:

> 
> On Tue, 2008-07-01 at 17:34 -0700, Andrew Morton wrote:
> > On Wed, 2 Jul 2008 01:19:27 +0200
> > Benoit Boissinot <bboissin@gmail.com> wrote:
> > 
> > > [who maintains random32.c ?]
> > 
> > ah.  I think it's ancient net code which was recently hoisted into lib/.
> > So: not really anybody.
> > 
> > I've been hopefully cc'ing Matt and Ted in the hope of fooling them
> > into looking at it.  But a netdev cc is appropriate also.
> 
> I did look at it, and it looks reasonable. So:
> 
> Acked-by: Matt Mackall <mpm@selenic.com>
> 
> Stephen Hemminger is responsible for the original code, I believe. I've
> been tempted to slurp this functionality into random.c but keep getting
> side-tracked into theoretical investigations of better functions, as I'm
> not a big fan of the current one from either a performance or strength
> perspective.
> 

Yes, I took it from gnu scientific lib it for use in netem.  The seeding
fixes make sense.

Note: this should not be a security issue since this routine is explicitly
not intended for cryptographic use.
