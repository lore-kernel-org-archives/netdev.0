From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Mon, 03 Sep 2012 13:23:03 -0400 (EDT)
Message-ID: <20120903.132303.1593263170604708814.davem@davemloft.net>
References: <1346629684.2563.78.camel@edumazet-glaptop>
	<20120903074718.GA14750@breakpoint.cc>
	<1346666238.2563.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, hvtaifwkbgefbaei@gmail.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2ICRXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 13:23:06 -0400
In-Reply-To: <1346666238.2563.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Sep 2012 11:57:18 +0200

> David, tell me if you prefer to change TCP demux to avoid timewait,
> as I have no strong opinion.

It would be the stupidest thing ever to do the whole hash lookup
just to throw the result away just because it's a timewait socket.

> [PATCH] net: sock_edemux() should take care of timewait sockets
> 
> sock_edemux() can handle either a regular socket or a timewait socket
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
