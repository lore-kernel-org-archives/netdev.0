From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-net] net: loopback: set default mtu to 64K
Date: Mon, 24 Sep 2012 16:24:42 -0400 (EDT)
Message-ID: <20120924.162442.1381532664983403691.davem@redhat.com>
References: <1348475339.26828.188.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893Ab2IXUYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 16:24:44 -0400
In-Reply-To: <1348475339.26828.188.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 10:28:59 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> loopback current mtu of 16436 bytes allows no more than 3 MSS TCP
> segments per frame, or 48 Kbytes. Changing mtu to 64K allows TCP
> stack to build large frames and significantly reduces stack overhead.
> 
> Performance boost on bulk TCP transferts can be up to 30 %, partly
> because we now have one ACK message for two 64KB segments, and a lower
> probability of hitting /proc/sys/net/ipv4/tcp_reordering default limit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This gives a nice %13 improvement on my SPARC-T4 box as well.

Applied, thanks Eric.
