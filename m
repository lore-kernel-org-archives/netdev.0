From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 22:42:03 +0800
Message-ID: <20100705144203.GA7638@gondor.apana.org.au>
References: <20100705120617.GA6267@gondor.apana.org.au> <1278334754.2877.173.camel@edumazet-laptop> <20100705132245.GA6876@gondor.apana.org.au> <1278336898.2877.212.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52457 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753Ab0GEOmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 10:42:09 -0400
Content-Disposition: inline
In-Reply-To: <1278336898.2877.212.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 05, 2010 at 03:34:58PM +0200, Eric Dumazet wrote:
>
> I see. We could :
> 
> Avoid this memset(skb->cb, 0, sizeof(skb->cb)) in fastpath.

Yeah I think this might work.  Although skb's are used in all
sorts of esoteric places (such as netlink which may not even be
related to networking) so I can't guarantee that every alloc_skb
caller does the right thing.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
