From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 09:25:23 +0800
Message-ID: <20090729012523.GA1583@gondor.apana.org.au>
References: <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090728.180647.241258705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48274 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755182AbZG2BZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 21:25:31 -0400
Content-Disposition: inline
In-Reply-To: <20090728.180647.241258705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 06:06:47PM -0700, David Miller wrote:
>
> More interesting to me is the case where the queue is not
> filled up, or is very nearly so. :-)

Do you mean the hardware queue? In that case perhaps Krishna's
proposal of bypassing the qdisc would be the best.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
