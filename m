From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 10:03:07 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
References: <20080819.041706.261399060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33223 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752751AbYHSRDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 13:03:38 -0400
In-Reply-To: <20080819.041706.261399060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, David Miller wrote:
>
>  114 files changed, 1533 insertions(+), 898 deletions(-)

David, this absolutely _has_ to stop.

We're after -rc3. Your network merges continue to be too f*cking large, 
and this has been going on for many months now. If you cannot throttle 
people, I will have to throttle you and stop pulling things.

I'm going to take this, but really - this isn't just new drivers or 
something like that that you've used as an excuse for big pulls before, 
this is a _lot_ of changes to existing code.

Tell your people to look at the regression list, and if it's not there, 
they should stop.

I realize that this problem is partly because when I see the pull requests 
from you, I effectively see a combined pull from multiple different 
sources, and in that sense it's not quite as big. But the networking pulls 
have _consistently_ had the problem that they keep on being big not just 
after -rc3, but after -rc4 and on, and I get the distinct feeling that 
you're not moving the pain downwards, and aren't telling the people under 
you to keep it clean and minimal and regressions only.

For example, those BT updates looked in no way like regression fixes. So 
what the f*ck were they doing there? And why do you think all those driver 
updates cannot cause new regressions? 

If it's not a regression fix, it shouldn't be there. It should be in the 
queue for the next version. Why is that apparently so hard for the network 
people?

		Linus
