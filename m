From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sun, 30 Sep 2007 08:26:01 +0800
Message-ID: <20070930002601.GB7502@gondor.apana.org.au>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3889 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751598AbXI3A0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 20:26:16 -0400
Content-Disposition: inline
In-Reply-To: <20070929.171339.59681016.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 05:13:39PM -0700, David Miller wrote:
> 
> The reason is that if we have to COW or resize the SKB it
> could result in a realloc of the sk_buff struct which is
> why we need the **pskb thing.
> 
> But strangely I can't find any skbuff.h interfaces that
> require that any longer :-)))  So this might be some artifact
> that we can in fact kill off.

Indeed.  The only other case I can think of is defragmentation.
But even there we should be able to squeeze it into the original
skb :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
