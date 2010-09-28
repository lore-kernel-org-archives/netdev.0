From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Tue, 28 Sep 2010 17:41:39 +0900
Message-ID: <20100928084139.GA26793@gondor.apana.org.au>
References: <1284987700.3420.333.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54698 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab0I1Ilp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 04:41:45 -0400
Content-Disposition: inline
In-Reply-To: <1284987700.3420.333.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> ipv6 can be a module, we should test CONFIG_IPV6 and CONFIG_IPV6_MODULE
> to enable ipv6 bits in ip_gre.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

To do this safely, we also need to disallow IPV6=m and GRE=y.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
