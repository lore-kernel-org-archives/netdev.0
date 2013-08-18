From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ipsec v2 3/3] xfrm: choose protocol family by skb protocol
Date: Sun, 18 Aug 2013 18:05:26 +0200
Message-ID: <20130818160526.GA9414@order.stressinduktion.org>
References: <20130818114701.GA10270@order.stressinduktion.org> <1376840901.21329.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59134 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab3HRQF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 12:05:28 -0400
Content-Disposition: inline
In-Reply-To: <1376840901.21329.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 18, 2013 at 08:48:21AM -0700, Eric Dumazet wrote:
> On Sun, 2013-08-18 at 13:47 +0200, Hannes Frederic Sowa wrote:
> > We need to choose the protocol family by skb->protocol. Otherwise we
> > call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
> > used in ipv4 mode, in which case we should call down to xfrm4_local_error
> > (ip6 sockets are a superset of ip4 ones).
> > 
> > We are called before before ip_output functions, so skb->protocol is
> > not reset.
> > 
> > v2:
> > a) unchanged
> > 
> > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> Hi Hannes
> 
> For your next patches, please add the v1/v2/v3 stuff _after_ the ---
> separator as in :
> 
> Normal changelog (will be included in git history)
> 
> Signed-off-by: ....
> Cc: ...
> ---
> v2: Fix (you can omit this line if there was no change between v2 and
> v1)
>  diffstat
>  diff
> 
> 
> This is to have clean changelogs, with high S/N ratio ;)

Of course, I can do so.

Actually, I thought having the changelog in the commit msg is an extra
plus (even it is mostly inexpressive) because one knows there could be
more than one thread on the mailing list regarding the commit.

Thanks,

  Hannes
