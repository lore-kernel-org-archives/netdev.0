From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed, 07 Aug 2013 16:40:56 -0700 (PDT)
Message-ID: <20130807.164056.2110811182336568861.davem@davemloft.net>
References: <1375898766.4004.37.camel@edumazet-glaptop>
	<20130807205959.GC21463@macbook.localnet>
	<20130807210540.GE32257@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab3HGXfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:35:41 -0400
In-Reply-To: <20130807210540.GE32257@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 7 Aug 2013 23:05:40 +0200

> It seems, Windows stopped using tcp timestamps at least in windows 8 by
> default.

Thankfully, Android device outnumber Windows 8 installs
by... something like 1,000 to 1, right?

I throw a huge "doesn't matter" to whatever Windows's TCP stack
decides to do.  It absolutely should not dictate whether we decide to
make use of this or that feature of TCP.  It's a bit player at best.

So if Windows 8 is the reason you're saying we shouldn't use
timestamps for anything, you're wrong.
