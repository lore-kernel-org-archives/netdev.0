From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 11:31:03 +0400
Message-ID: <20060807073103.GA11283@2ka.mipt.ru>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au> <20060807072423.GA2078@2ka.mipt.ru> <20060807072816.GA5404@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:22452 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751131AbWHGHbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 03:31:19 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060807072816.GA5404@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 05:28:16PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Mon, Aug 07, 2006 at 11:24:23AM +0400, Evgeniy Polyakov wrote:
> >
> > > I'd hope not.  Apparently they are capable of putting data into
> > > individual pages and chaining them together.  The only problem
> > 
> > Unfortunately not all chips are capable to do this.
> 
> No not all chips are capable of header-splitting.  However, from what
> Jesse was saying it sounded as if all (or most?) chips are capable of
> storing data cross pages.

Only if they form contiguous region?
Jesse, is it possible for every e1000 chip to split frame into several
page-sized chunks i.e. create some kind of receiving scatter-gather?

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
	Evgeniy Polyakov
