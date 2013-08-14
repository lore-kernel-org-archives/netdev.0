From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: introduce helper for safe determination of mtu
Date: Wed, 14 Aug 2013 14:23:46 +0200
Message-ID: <20130814122346.GL26773@secunet.com>
References: <20130813023558.GD27385@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37180 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932125Ab3HNMXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 08:23:49 -0400
Content-Disposition: inline
In-Reply-To: <20130813023558.GD27385@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 04:35:58AM +0200, Hannes Frederic Sowa wrote:
> skb->sk socket can be of AF_INET or AF_INET6 address family. Thus we
> always have to make sure we a referring to the correct interpretation
> of skb->sk.
> 
> We only depend on header defines to query the mtu, so we don't introduce
> a new dependency to ipv6 by this change.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Also applied to ipsec, thanks!
