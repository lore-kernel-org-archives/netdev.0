From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 11:24:23 +0400
Message-ID: <20060807072423.GA2078@2ka.mipt.ru>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:388 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751123AbWHGHYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 03:24:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G9zMP-0001MO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 05:17:13PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> David Miller <davem@davemloft.net> wrote:
> > 
> > I don't know if I want to eat an entire extra allocation for every SKB
> > just to handle broken e1000 cards that can't be bothered to support
> > non-power-of-2 receive buffer sizes and a proper MTU setting.
> > 
> > I guess we might have to, but this is extremely unfortunate. :-/
> 
> I'd hope not.  Apparently they are capable of putting data into
> individual pages and chaining them together.  The only problem

Unfortunately not all chips are capable to do this.

-- 
	Evgeniy Polyakov
