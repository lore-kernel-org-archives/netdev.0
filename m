From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Fix dev->qdisc race for NETDEV_TX_LOCKED case
Date: Thu, 10 May 2007 21:58:32 +1000
Message-ID: <20070510115832.GA25171@gondor.apana.org.au>
References: <20070510094228.GG521@postel.suug.ch> <E1Hm7Er-0006Wk-00@gondolin.me.apana.org.au> <20070510.045618.36663267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2786 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754453AbXEJL6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:58:40 -0400
Content-Disposition: inline
In-Reply-To: <20070510.045618.36663267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 04:56:18AM -0700, David Miller wrote:
> 
> Applied to my tree and I'll push it off to Linus tomorrow unless
> someone finds a problem with it by then.

BTW, guess how this bug was introduced? By the lockless patch,
surprise surprise :)

The sooner we are rid of it the better.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
