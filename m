From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net RESEND v2] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 12:15:34 +0200
Message-ID: <20130711101534.GA5207@order.stressinduktion.org>
References: <20130710210012.GK15411@order.stressinduktion.org> <20130710.173633.631366598766526289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, petrus.lt@gmail.com,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:38798 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab3GKKPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 06:15:36 -0400
Content-Disposition: inline
In-Reply-To: <20130710.173633.631366598766526289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 05:36:33PM -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 10 Jul 2013 23:00:12 +0200
> 
> > I changed the return value of rt6_check_neigh to:
> >    1 in case of the dst entry validated
> >   -1 in case of we had no dst_entry and we need to do rr now
> >   -2 in case a we had a dst_entry and it did not validate
> 
> Please, at the very least, create an enumeration for this set of
> possible return values.

Yes, this should have caught my eyes earlier.

> Although I don't like how that RR boolean is passed around by
> reference, I can't suggest anything better so I won't require
> you to get rid of that.

I fear so, too. I also tought about marking the soft-fail state in the
pointer or adding a rt6_match structure. But both seem more complex to me.

Will send an updated patch shortly.

Thanks,

  Hannes
