From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Mon, 14 Jul 2008 19:33:02 +0800
Message-ID: <E1KIMIg-0007MB-00@gondolin.me.apana.org.au>
References: <4877C76B.6010504@cosmosbay.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36281 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751614AbYGNLdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 07:33:11 -0400
In-Reply-To: <4877C76B.6010504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>> +     return hash % dev->real_num_tx_queues;
> 
> simple but expensive... but could be changed to use reciprocal_divide() if necessary...

For the common cases it should be a power of 2 too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
