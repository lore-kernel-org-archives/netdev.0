From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 13:47:59 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191341150.3324@nehalem.linux-foundation.org>
References: <20080819.041706.261399060.davem@davemloft.net> <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org> <20080819.131454.223684377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39968 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbYHSUsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 16:48:03 -0400
In-Reply-To: <20080819.131454.223684377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, David Miller wrote:
> 
> The BT bits were the only part I really considered borderline,
> and I was going to push back on Marcel.

I really don't see the e1000 and netxen updates as being critical either. 
Sure, they look like driver improvement, but "improvement" is not what the 
-rc3+ series is about. 

Same goes for all the loopback changes. They look like cleanups or feature 
enables.

IOW, it all looks like good commits, but quite a _lot_ of that queue looks 
like good commits that should happen during the merge window, not during 
the stabilization phase.

And this is by no means unique to _this_ pull request. It's been a very 
clear pattern for a long time now. The networking area tends to be one of 
the absolutely *most* active ones during the post-rc1 phase.

[ Yeah, in all fairness some architectures also do that, but at least I 
  feel like I _really_ don't need to care when I get a diffstat that only 
  touches arch/sh/* or something like that. ]

> But to be honest, I haven't seen bluetooth updates from him
> for such a long time I felt that being strict here would just
> exacerbate the problem.

I pointed out the BT ones as standing out (they were larger than some of 
the other patches too), but I really don't think this was in any way 
limited to BT in any shape, form or color. Quite frankly, looking through 
the thing, my gut feel is that about _half_ the commits over-all should 
probably have been in the queue for the next release.

		Linus
