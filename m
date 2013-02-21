From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Fri, 22 Feb 2013 00:06:13 +0100
Message-ID: <20130221230613.GB9671@order.stressinduktion.org>
References: <1361485132.17413.19.camel@edumazet-glaptop> <20130221224316.GA9671@order.stressinduktion.org> <1361486903.32484.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49349 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab3BUXGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 18:06:15 -0500
Content-Disposition: inline
In-Reply-To: <1361486903.32484.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 02:48:23PM -0800, Eric Dumazet wrote:
> On Thu, 2013-02-21 at 23:43 +0100, Hannes Frederic Sowa wrote:
> 
> > 
> > Perhaps we should use ipv6_addr_jhash in the destination cache, too, and look
> > at other uses of ipv6_addr_hash?
> 
> Sure, an audit is needed, but with tcp early demux, TCP lookup was the
> first weak point.

I had two simple programs to test this. Perhaps they could be helpful
to somebody:

tcpproxy.c - does 3whs and teardown
gensyn6.c -  generates syn packets from /64 range

https://gist.github.com/hannes/5009267
