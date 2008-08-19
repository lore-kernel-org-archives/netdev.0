From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Tue, 19 Aug 2008 23:03:41 +1000
Message-ID: <E1KVQs9-0001Sm-00@gondolin.me.apana.org.au>
References: <20080818.222917.10471071.davem@davemloft.net>
Cc: kaber@trash.net, netdev@vger.kernel.org, jarkao2@gmail.com
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58526 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753678AbYHSNDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:03:47 -0400
In-Reply-To: <20080818.222917.10471071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> Maybe we can simply add a "bool peek" argument or some flags to
> ->dequeue() instead.

Yeah a peek + the forced dequeue of a specific skb should be
sufficient to replace requeue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
