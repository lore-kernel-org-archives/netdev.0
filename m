From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Wed, 19 Jul 2006 05:43:18 +1000
Message-ID: <20060718194318.GA15572@gondor.apana.org.au>
References: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil> <44BD2636.1010105@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24595 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932332AbWGRToA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 15:44:00 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
Content-Disposition: inline
In-Reply-To: <44BD2636.1010105@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 08:19:34PM +0200, Guillaume Chazarain wrote:
>
> Why not clearing the whole IPCB(skb) instead of
> just IPCB(skb)->opts? that would also clear
> IPCB(skb)->flags.

I agree, we should clear the whole IPCB.

> And, does not ipv6 need the same treatment with
> IP6CB?

Probably.  Patches are welcome :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
