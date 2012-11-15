From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Thu, 15 Nov 2012 09:21:58 +0100
Message-ID: <20121115082158.GM22290@secunet.com>
References: <20121108.145939.2274479010583117059.davem@davemloft.net>
 <20121109075726.GD22290@secunet.com>
 <20121113090006.GI22290@secunet.com>
 <20121114.185528.2167305838484743723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56105 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028Ab2KOIWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 03:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20121114.185528.2167305838484743723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 14, 2012 at 06:55:28PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 13 Nov 2012 10:00:06 +0100
> 
> > Subject: [PATCH] xfrm: Fix the gc threshold value for ipv4
> > 
> > The xfrm gc threshold value depends on ip_rt_max_size. This
> > value was set to INT_MAX with the routing cache removal patch,
> > so we start doing garbage collecting when we have INT_MAX/2
> > IPsec routes cached. Fix this by going back to the static
> > threshold of 1024 routes.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> This looks fine to me.

I've just applied this to the ipsec tree.

I'll do the same for the ipv6 side. ipv6 does not handle the maximum
number of routes dynamically, so no need to try to handle the IPsec
gc threshold dynamically.
