From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 5 Aug 2008 19:57:03 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org>
References: <20080805.190020.244441681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivo van Doorn <IvDoorn@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45232 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752844AbYHFC5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 22:57:07 -0400
In-Reply-To: <20080805.190020.244441681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 5 Aug 2008, David Miller wrote:
> 
> There was going to be the addition of the ath9k wireless driver but
> there was some fallout that is being worked on right now (linux/list.h
> changes needed lkml review, ath9k driver triggered some gcc aborts,
> all kinds of fun stuff :-) so hopefully it will make it in the next
> pass.  I tried to wait an extra day for it to be resolved, but that
> was optimistic.

Talking about wireless driver updates - has anybody looked at the RaLink 
wireless driver?  It's in the newer EeePC's (901 and 1000), and it 
actually has a driver from the company which the comments make clear is 
GPLv2 too, no apparent oddness or anything:

	http://www.ralinktech.com.tw/data/drivers/2008_0708_RT2860_Linux_STA_v1.7.0.0.tar.bz2

which admittedly apparently has some trivial problems (with a trivial 
patch as seen at

	http://fedoraforum.org/forum/showthread.php?t=195429

I'd love to have that one working, since I have the hardware, and it's 
actually reasonable (much more so than the original EeePC, in fact). What 
channels should I go through? Is anybody working on integrating it 
already?

(Ivo van Doorn added to Cc, since he seems the go-to guy for the rt2x00 
driver in the tree, and may have some input).

		Linus
