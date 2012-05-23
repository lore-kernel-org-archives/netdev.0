From: David Miller <davem@davemloft.net>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 13:57:27 -0400 (EDT)
Message-ID: <20120523.135727.414815976542132549.davem@davemloft.net>
References: <1337766246.3361.2447.camel@edumazet-glaptop>
	<20120523.133401.915684077769386834.davem@davemloft.net>
	<1337795210.3361.3118.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kmansley@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933782Ab2EWR5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 13:57:33 -0400
In-Reply-To: <1337795210.3361.3118.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 May 2012 19:46:50 +0200

> But TCP already backs off if user process is not blocked on socket
> input.
> 
> Modern applications uses select()/poll()/epoll() on many sockets in //.
> 
> Only old ones stil block on recv().

These arguments seem circular.

Those modern applications still trigger enough TCP work during their
recv() calls that it's significant enough for scheduling purposes, and
to me being able to account that TCP work as process time is still
extremely beneficial.
