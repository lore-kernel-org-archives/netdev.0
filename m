From: Willy Tarreau <w@1wt.eu>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 06:20:29 +0200
Message-ID: <20080820042029.GA31789@1wt.eu>
References: <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org> <20080819.142150.129314008.davem@davemloft.net> <1219199116.26429.19.camel@jdub.homelinux.org> <20080819.195115.49989151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jwboyer@gmail.com, torvalds@linux-foundation.org,
	marcel@holtmann.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1100 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbYHTEVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 00:21:09 -0400
Content-Disposition: inline
In-Reply-To: <20080819.195115.49989151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 07:51:15PM -0700, David Miller wrote:
> From: Josh Boyer <jwboyer@gmail.com>
> Date: Tue, 19 Aug 2008 22:25:15 -0400
> 
> > So, not to add fuel to a fire that seems to be calming down, but what is
> > so wrong with having that feeling?  If the core people are spending 3
> > months doing nothing but fixing bugs, the I consider that to _be_ the
> > best work from the best people.
> 
> All work and no play makes Dave a dull boy, that's the
> problem. :-)
> 
> I don't care how much someone claims they enjoy bug fixing
> and gathering up other people's patches, you will go out
> of your mind or become bored to death if you don't get to
> spend real time implementing something significant from
> time to time.

That's true and I would also add that it's very common for bugs to
be discovered and fixed while implementing new features. However,
it's so convenient to manage several branches with git that it should
not be a problem to "play" in one branch and push all the stuff during
the merge window only. One of the problems with networking is that you
need a lot of testers. I don't think it's too hard for them to pull
from your development tree. And if it is, maybe you can incite them
from time to time by releasing snapshots as plain patches.

BTW, it also helps testers a lot to be able to play with topic trees
provided as patches against last release, because they generally can
apply them to stable kernels without the fear of losing their data.
I'm sure that many people already run stable kernels with not-yet-merged
patches on top of them and are happy that way.

Regards,
Willy

