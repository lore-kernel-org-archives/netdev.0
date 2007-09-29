From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sat, 29 Sep 2007 08:51:00 +0800
Message-ID: <20070929005100.GA31959@gondor.apana.org.au>
References: <20070927073446.GA14643@gondor.apana.org.au> <1190896785.4290.18.camel@localhost> <20070927.120803.39482469.davem@davemloft.net> <46FD3204.6090305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1449 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755821AbXI2Avk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 20:51:40 -0400
Content-Disposition: inline
In-Reply-To: <46FD3204.6090305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 06:55:32PM +0200, Patrick McHardy wrote:
>
> Looking at ip_input.o as example (everything without forced inlining):
> 
>    text    data     bss     dec     hex filename
>    2076       8       0    2084     824 net/ipv4/ip_input.o
>    3483       8       0    3491     da3 net/ipv4/ip_input.o

If it's so big perhaps it should be inlined? It'll be a tail
call anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
