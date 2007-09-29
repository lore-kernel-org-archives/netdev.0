From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sat, 29 Sep 2007 11:37:21 +0800
Message-ID: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au>
References: <20070929005100.GA31959@gondor.apana.org.au>
Cc: kaber@trash.net, davem@davemloft.net, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au (Herbert Xu)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2275 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752886AbXI2Dhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 23:37:36 -0400
In-Reply-To: <20070929005100.GA31959@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Sep 28, 2007 at 06:55:32PM +0200, Patrick McHardy wrote:
>>
>> Looking at ip_input.o as example (everything without forced inlining):
>> 
>>    text    data     bss     dec     hex filename
>>    2076       8       0    2084     824 net/ipv4/ip_input.o
>>    3483       8       0    3491     da3 net/ipv4/ip_input.o
> 
> If it's so big perhaps it should be inlined? It'll be a tail
> call anyway.

s/should be/shouldn't be/
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
