From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Thu, 3 Jan 2013 13:57:36 +0100
Message-ID: <20130103125736.GI4464@order.stressinduktion.org>
References: <20130103000009.GG4464@order.stressinduktion.org> <1357217260.21409.24224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33801 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab3ACM5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 07:57:37 -0500
Content-Disposition: inline
In-Reply-To: <1357217260.21409.24224.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2013 at 04:47:40AM -0800, Eric Dumazet wrote:
> On Thu, 2013-01-03 at 01:00 +0100, Hannes Frederic Sowa wrote:
> > ECN could be more reliable when used with IPv6 (I don't have proofs). For
> > people who want to try ECN with IPv6 but still have problems connecting
> > to destinations because of broken IPv4 routers this switch allows one
> > to enable ECN just for IPv6.
> > 
> > Perhaps ECN could be enabled by default in future.
> > 
> > No code changes since initial submission, just added documentation.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> It would be nice to make the ecn sysctl per net namespace.
> 
> Do you have an idea of how to adapt your patch to get this as well ?

Currently not, but I will try. :)

Is the direction to split the sysctl ok? Or should it be a unified sysctl for
ipv4/ipv6 and only be separate per namespace?

Thanks!
