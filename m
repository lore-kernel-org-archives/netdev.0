From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 17:28:16 +1000
Message-ID: <20060807072816.GA5404@gondor.apana.org.au>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au> <20060807072423.GA2078@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15628 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751129AbWHGH2f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 03:28:35 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060807072423.GA2078@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 11:24:23AM +0400, Evgeniy Polyakov wrote:
>
> > I'd hope not.  Apparently they are capable of putting data into
> > individual pages and chaining them together.  The only problem
> 
> Unfortunately not all chips are capable to do this.

No not all chips are capable of header-splitting.  However, from what
Jesse was saying it sounded as if all (or most?) chips are capable of
storing data cross pages.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
