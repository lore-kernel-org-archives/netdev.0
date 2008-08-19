From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:21:50 -0700 (PDT)
Message-ID: <20080819.142150.129314008.davem@davemloft.net>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	<1219170451.7591.175.camel@violet.holtmann.net>
	<alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751073AbYHSVVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:21:51 -0400
In-Reply-To: <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Aug 2008 13:54:03 -0700 (PDT)

> As it is, it seems like some people think that the merge window is when 
> you send any random crap that hasn't even been tested, and then after the 
> merge window you send the stuff that looks "obviously good".

We are perpetuating this mind set, aren't we?  I could be wrong
but this is how I see things currently.

I agree, we should be working on regressions fixes now.  And we should
essentially be doing so up until the merge window opens up again,
right?

When do people following those rules have time to work on new stuff?
Especially people like me who have to review and merge everyone else's
work as well as help fix bugs.

And not just subsystem maintainers like me, it's also the same for
people who are experienced, dilligent, and work on fixing bugs.
That kind of work is very time consuming.

So given that, who spends a decent amount of time working on features?
People who aren't dilligent working on bugs before the merge window,
and new developers, that's who.

linux-next is great, I love it, it solves all the merge hassles that
used to knock us out during the merge window and make life hell.

But it doesn't fix the time delegation problem.

There is always this "oh crap, I just spent 3 months doing nothing
but fixing bugs" feeling a lot of us core folks get right before
the merge window opens up.

So instead of getting the best work from the best people we have,
we get this last minute flurry of development in the days leading
up to the merge window openning up.

Maybe it's just a longing for the golden era of 2.${ODD}.x style
development, who knows :-)
