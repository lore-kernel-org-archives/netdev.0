From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix sorting of SACK blocks
Date: Fri, 26 Jan 2007 00:42:19 -0800 (PST)
Message-ID: <20070126.004219.11627875.davem@davemloft.net>
References: <20070125182903.GA22455@galon.ev-en.org>
	<20070125.155532.78711708.davem@davemloft.net>
	<20070126064009.GE22455@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030819AbXAZImU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 03:42:20 -0500
In-Reply-To: <20070126064009.GE22455@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Fri, 26 Jan 2007 08:40:09 +0200

> You actually need recv_sack_cache to detect if you can use the fast
> path. Another alternative is to somehow hash the values of the sack
> blocks but then you rely on probabilty that you will properly detect the
> ability to use the fast path. Hashing will save some space but you can't
> get rid of it completely unless you go back to the old and slow method
> of SACK processing.
> 
> There were thoughts thrown a while back about using a different data
> structure, I think you said you started working on something like that.
> If that comes to fruition the cache might go.

I don't know if those ideas will go anywhere, it's difficult
to make it work properly and it has to be done right since we'll
likely have to change drivers to handle an aggregated send queue
cleanly and we only want to do that once.

> FWIW, my other mail about possible bugs actually says that you might
> need to add another value to check, the number of sack blocks in the
> cache.

Yes I saw that, I was about to go over that and maybe come up with
some patches.
