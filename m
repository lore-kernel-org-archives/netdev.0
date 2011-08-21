From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: 20 Aug 2011 23:04:15 -0400
Message-ID: <20110821030415.18106.qmail@science.horizon.com>
References: <20110821012844.GA15222@1wt.eu>
Cc: dan@doxpara.com, davem@davemloft.net, gerrit@erg.abdn.ac.uk,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	mpm@selenic.com, netdev@vger.kernel.org
To: linux@horizon.com, w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:41677 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752301Ab1HUDEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 23:04:16 -0400
In-Reply-To: <20110821012844.GA15222@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> * Should I worry about 32-bit IPv6 performance, since that's even more
>>   unlikely to be running heavy loads on 32-bit hardware?

> On x86 you're probably right, but there are other very fast platforms
> such as ARM, which are used to build routers or appliances, and which
> are 32-bit and there it may matter.

Thanks for the feedback.  Your point about routers is well-taken.
It's particularly x86-32 which gives me fits, but I'll keep ARM
performance in mind, too.

>> * If yes, is this fast enough to be acceptable, or do I need to work
>>   harder to find more speed?

> I'd suggest that the most important is no performance regression. Probably
> that if you can bring something which brings back what we lost with MD5,
> your work would gain interest.

Okay, I'll go back to the drawing board on performance.

Damn, this is going to be tough.

> I'm copy-pasting here the memo I exchanged in private after my tests, there
> is nothing secret in it, so better post the whole explanation :

Thank you very much.  It helps me figure out what the time budget is.
