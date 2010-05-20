From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 12:57:42 +1000
Message-ID: <20100520025741.GA6129@gondor.apana.org.au>
References: <20100519180053.GC26519@hmsreliant.think-freely.org> <1274302191.3148.2.camel@lsx.localdomain> <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:54395 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752381Ab0ETC6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 22:58:00 -0400
Content-Disposition: inline
In-Reply-To: <20100519.195533.22536631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 07:55:33PM -0700, David Miller wrote:
> 
> Since it seems now inevitable to me that we'll need to store the
> 'classid' in struct sk_buff, I've prepared two patches to do that at
> zero cost.

Actually I'm currently working on a patch to store this in struct
sock.  The reason I prefer struct sock is because we can then
centralise the place where we set the classid rather than having
it spread out through every place that creates an skb.

I'll post it soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
