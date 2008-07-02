From: Matt Mackall <mpm@selenic.com>
Subject: Re: Bug in random32.c: all-zero outputs with probability 1/2^32,
	other seeding bugs
Date: Tue, 01 Jul 2008 22:22:31 -0500
Message-ID: <1214968951.11311.122.camel@calx>
References: <20080619153045.GC1455@randombit.net>
	 <20080701231927.GW7647@pirzuine>
	 <20080701173405.cb28db84.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Benoit Boissinot <bboissin@gmail.com>,
	linux-kernel@vger.kernel.org, lloyd@randombit.net,
	"Theodore Ts'o" <tytso@mit.edu>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:35437 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbYGBDXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 23:23:44 -0400
In-Reply-To: <20080701173405.cb28db84.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-07-01 at 17:34 -0700, Andrew Morton wrote:
> On Wed, 2 Jul 2008 01:19:27 +0200
> Benoit Boissinot <bboissin@gmail.com> wrote:
> 
> > [who maintains random32.c ?]
> 
> ah.  I think it's ancient net code which was recently hoisted into lib/.
> So: not really anybody.
> 
> I've been hopefully cc'ing Matt and Ted in the hope of fooling them
> into looking at it.  But a netdev cc is appropriate also.

I did look at it, and it looks reasonable. So:

Acked-by: Matt Mackall <mpm@selenic.com>

Stephen Hemminger is responsible for the original code, I believe. I've
been tempted to slurp this functionality into random.c but keep getting
side-tracked into theoretical investigations of better functions, as I'm
not a big fan of the current one from either a performance or strength
perspective.

-- 
Mathematics is the supreme nostalgia of our time.

