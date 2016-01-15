From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] ipv6: update skb->csum when CE mark is propagated
Date: Fri, 15 Jan 2016 21:45:15 +0800
Message-ID: <20160115134515.GA31463@gondor.apana.org.au>
References: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44042 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbcAONpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 08:45:20 -0500
Content-Disposition: inline
In-Reply-To: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 04:56:56AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When a tunnel decapsulates the outer header, it has to comply
> with RFC 6080 and eventually propagate CE mark into inner header.
> 
> It turns out IP6_ECN_set_ce() does not correctly update skb->csum
> for CHECKSUM_COMPLETE packets, triggering infamous "hw csum failure"
> messages and stack traces.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
