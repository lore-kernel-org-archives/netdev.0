From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 19:51:05 -0400 (EDT)
Message-ID: <20150518.195105.2072041210798369557.davem@davemloft.net>
References: <20150518204049.GC20709@breakpoint.cc>
	<20150518.165550.359134808190719687.davem@davemloft.net>
	<20150518213329.GA2335@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbbERXvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 19:51:08 -0400
In-Reply-To: <20150518213329.GA2335@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 18 May 2015 23:33:29 +0200

> Thanks for spending time on this.

Ok, I've heard what you have to say.

Of the fixes you've proposed already, I prefer the device MTU one
because it doesn't penalize the ip_fragment.c optimizations just
because a netfilter module is loaded.

Which of your already proposed patches do you prefer, and why?

I'm happy to apply one or the other as an interim step to make
forward progress.  However, I really want to seriously consider
our long term handling of fragments in netfilter meanwhile.

Thanks.
