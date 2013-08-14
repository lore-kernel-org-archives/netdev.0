From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] xfrm: make local error reporting more robust
Date: Wed, 14 Aug 2013 14:22:13 +0200
Message-ID: <20130814122213.GK26773@secunet.com>
References: <20130814110523.GG16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37040 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759697Ab3HNMWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 08:22:16 -0400
Content-Disposition: inline
In-Reply-To: <20130814110523.GG16264@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 01:05:23PM +0200, Hannes Frederic Sowa wrote:
> In xfrm4 and xfrm6 we need to take care about sockets of the other
> address family. This could happen because a 6in4 or 4in6 tunnel could
> get protected by ipsec.
> 
> Because we don't want to have a run-time dependency on ipv6 when only
> using ipv4 xfrm we have to embed a pointer to the correct local_error
> function in xfrm_state_afinet and look it up when returning an error
> depending on the socket address family.
> 
> Thanks to vi0ss for the great bug report:
> <https://bugzilla.kernel.org/show_bug.cgi?id=58691>
> 
> v2:
> a) fix two more unsafe interpretations of skb->sk as ipv6 socket
>    (xfrm6_local_dontfrag and __xfrm6_output)
> v3:
> a) add an EXPORT_SYMBOL_GPL(xfrm_local_error) to fix a link error when
>    building ipv6 as a module (thanks to Steffen Klassert)
> 
> Reported-by: <vi0oss@gmail.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to ipsec, thanks a lot Hannes!
