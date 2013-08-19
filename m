From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec v2 3/3] xfrm: choose protocol family by skb protocol
Date: Mon, 19 Aug 2013 13:46:25 +0200
Message-ID: <20130819114625.GX26773@secunet.com>
References: <20130818114701.GA10270@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44077 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab3HSLq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 07:46:28 -0400
Content-Disposition: inline
In-Reply-To: <20130818114701.GA10270@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 18, 2013 at 01:47:01PM +0200, Hannes Frederic Sowa wrote:
> We need to choose the protocol family by skb->protocol. Otherwise we
> call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
> used in ipv4 mode, in which case we should call down to xfrm4_local_error
> (ip6 sockets are a superset of ip4 ones).
> 
> We are called before before ip_output functions, so skb->protocol is
> not reset.
> 
> v2:
> a) unchanged
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

All applied to the ipsec tree, thanks a lot!
