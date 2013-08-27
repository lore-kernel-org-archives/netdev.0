From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/2] ipv6: set skb->protocol on tcp, raw and
 ip6_append_data genereated skbs
Date: Tue, 27 Aug 2013 11:23:56 +0200
Message-ID: <20130827092356.GB7660@secunet.com>
References: <20130826103123.GA30508@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48804 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111Ab3H0JX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 05:23:59 -0400
Content-Disposition: inline
In-Reply-To: <20130826103123.GA30508@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 12:31:23PM +0200, Hannes Frederic Sowa wrote:
> Currently we don't initialize skb->protocol when transmitting data via
> tcp, raw(with and without inclhdr) or udp+ufo or appending data directly
> to the socket transmit queue (via ip6_append_data). This needs to be
> done so that we can get the correct mtu in the xfrm layer.
> 
> Setting of skb->protocol happens only in functions where we also have
> a transmitting socket and a new skb, so we don't overwrite old values.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Also applied to ipsec, thanks a lot!
