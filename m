From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Fri, 3 Sep 2010 05:26:17 +0800
Message-ID: <20100902212617.GA25150@gondor.apana.org.au>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net> <20100902083327.GA6246@ff.dom.local> <1283419909.2454.137.camel@edumazet-laptop> <20100902095502.GA8775@ff.dom.local> <1283424105.2454.311.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44050 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757241Ab0IBV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 17:26:23 -0400
Content-Disposition: inline
In-Reply-To: <1283424105.2454.311.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 12:41:45PM +0200, Eric Dumazet wrote:
> 
> [PATCH net-next-2.6] gro: remove use of napi->dev
> 
> Only use of napi->dev in GRO stack is the one found in napi_get_frags()
> 
> We can remove it and use a plain dev_alloc_skb() call.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Why do you think napi->dev is not needed?
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
