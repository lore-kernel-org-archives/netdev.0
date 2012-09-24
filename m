From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 16:53:07 -0400 (EDT)
Message-ID: <20120924.165307.848844032342514886.davem@davemloft.net>
References: <20120924153921.GA13845@redhat.com>
	<1348504445.26828.1131.camel@edumazet-glaptop>
	<1348506011.26828.1195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, ycheng@google.com, ja@ssi.bg,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab2IXUxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:53:11 -0400
In-Reply-To: <1348506011.26828.1195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 19:00:11 +0200

> Signed-off-by: Eric Dumazet <edumazet@google.com>

I know you meant "From: Eric Dumazet <edumazet@google.com>"
here :-)

> [PATCH] net: guard tcp_set_keepalive() to tcp sockets
> 
> Its possible to use RAW sockets to get a crash in 
> tcp_set_keepalive() / sk_reset_timer()
> 
> Fix is to make sure socket is a SOCK_STREAM one.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
