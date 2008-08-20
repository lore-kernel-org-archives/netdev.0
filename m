From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 05:42:33 +0200
Message-ID: <1219203753.7591.205.camel@violet.holtmann.net>
References: <20080819.041706.261399060.davem@davemloft.net>
	 <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	 <1219170451.7591.175.camel@violet.holtmann.net>
	 <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42618 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbYHTDmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 23:42:31 -0400
In-Reply-To: <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

> > Also I cleaned up the MAINTAINERS file entries for Bluetooth. Are these
> > considered harmful now and should be postponed to the next merge window?
> > They can obviously not introduce any regressions?
> 
> What I consider harmful is not any individual commit per se, but the 
> mindset that clearly says "hey, this particular commit is good, let's 
> push it up".

again, my current understanding was that updates to the documentation
that would help people to navigate and understand the kernel better and
make it easier for them to do bug reports etc. are always welcome and
should be pushed immediately. Same goes for new drivers that would
enable people to use their hardware.

If you don't want these patches during the -rc phase, then this is fine
by me. It is no extra work for me to queue these up until the next merge
window. Actually GIT makes merges for me so simple that I couldn't care
less. I was mislead that you want these kind of fixes to go in quickly
and I apologize for the trouble. I will stop bothering Dave with these
from now on and wait until the next merge window.

> And all of the commits are _individually_ fine and the likelihood for 
> breakage is probably damn low, but when you have lots of them, that 
> doesn't work any more. 
> 
> The whole point of the merge window is that you should be sending good, 
> tested commits _then_. And if you miss the merge window, then you queue 
> them up for the next one.
> 
> As it is, it seems like some people think that the merge window is when 
> you send any random crap that hasn't even been tested, and then after the 
> merge window you send the stuff that looks "obviously good".
> 
> How about raising your quality control a bit, so that I don't have to 
> berate you? Send the _obviously good_ stuff during the merge window, and 
> don't send the "random crap" AT ALL. And then, during the -rc series, you 
> don't do any "obviously good" stuff at all, but you do the "absolutely 
> required" stuff. 
> 
> The rule should be that if you have any doubt _what-so-ever_ that 
> something is absolutely required, you simply don't send it during the -rc 
> phase. And if you have any doubt at all about something not working, you 
> don't send it during the merge window either!
> 
> The merge window is not for "let's get this tested, so that we can fix it 
> during the -rc". And the stabilization phase is not for "this one looks 
> obviously correct and safe".

I get your point! And I was never using the merge window for "random
crap". All my stuff is heavily tested and even on non-x86 systems.

So why does it happen that I touched the MAINTAINERS file outside the
merge window? Simply because I ran into it looking what it says and then
fixed it. And when I had the regression fix for Dave to pull, I picked
the other two patches that couldn't introduce any regression and send it
with it. You don't want these. I get it and from now on they will stay
in my queue until the next merge window.

Regards

Marcel


