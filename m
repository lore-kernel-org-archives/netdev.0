From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 13:36:42 +0900
Message-ID: <20100929043642.GA3660@gondor.apana.org.au>
References: <20100928084139.GA26793@gondor.apana.org.au> <1285663738.2607.30.camel@edumazet-laptop> <1285733911.22570.20.camel@edumazet-laptop> <1285734295.22570.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45730 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab0I2Egt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 00:36:49 -0400
Content-Disposition: inline
In-Reply-To: <1285734295.22570.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 06:24:55AM +0200, Eric Dumazet wrote:
>
> Well, we all know icmpv6_cleanup() is not really called (or can we
> really unload ipv6 ?).
> 
> But unregister_icmpv6_send() should be the first call in it.

Do we really need to support IPV6=m and GRE=y? It might be simpler
to just behave as if IPv6 is off when this combination is given.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
