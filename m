From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:46:46 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191440440.3324@nehalem.linux-foundation.org>
References: <20080819.140458.236030589.davem@davemloft.net> <200808192315.48718.rjw@sisk.pl> <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org> <20080819.143556.245692295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rjw@sisk.pl, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38982 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752725AbYHSVrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:47:08 -0400
In-Reply-To: <20080819.143556.245692295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, David Miller wrote:
> 
> That change was made under the pretext that it was tested heavily and
> that if we hit any problem whatsoever with it that we couldn't fix
> quickly it would be reverted.

David, I will say this one more time:

 - as long as you concentrate on individual commits, you're missing the 
   big picture.

you can _always_ make excuses for individual commits. That's not my point. 
Or rather, it actually verry much _is_ my point. If you have the mindset 
that you're looking for excuses why any individual commit is ok to merge, 
then you don't end up with a coupld of individual commits any more: you 
end up with a LOT OF CHURN.

It's not the individual commits. You're looking at the individual trees, 
and you're missing the forest. The problem isn't the individual trees. The 
problem is that there's a metric sh*tload of individual trees, what we in 
the tree industry call a 'forest'. You're not seeing it.

And btw, don't get me wrong - you're not the only problem spot. During the 
-rc's leading up to 2.6.26, drivers/merdia was actually a _bigger_ 
problem. I happen to care less about that (the same way I care less about 
some odd-ball architectures), but I have to admit that drivers/media was a 
total disaster last time around.

So if it makes you feel any better, others have been even worse.  But this 
networking problem ha been going on for quite a while.

So the problem here really is that you seem overly eager to make excuses 
for individual patches. And if they _stayed_ "individual" it would all be 
good. But they don't seem to.

			Linus
