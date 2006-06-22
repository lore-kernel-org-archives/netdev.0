From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Export accept queue len of a TCP listening socket via	/proc/net/tcp{6}
Date: Thu, 22 Jun 2006 10:21:30 +1000
Message-ID: <E1FtCws-0005in-00@gondolin.me.apana.org.au>
References: <1150934207.2868.24.camel@w-sridhar2.beaverton.ibm.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1292 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932142AbWFVAVq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 20:21:46 -0400
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <1150934207.2868.24.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> In order to support this with netstat/ss that use netlink mechanism to
> get the socket info, i think we need to extend tcp_info to add this field.
> Can this be done in a backward compatible way?

What about using the same fields (rqueue/wqueue) as you did for /proc?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
