From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 22:59:21 +1100
Message-ID: <20090107115921.GA25323@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107112906.GA28161@ioremap.net> <20090107115032.GA25198@gondor.apana.org.au> <20090107115605.GA29250@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47939 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750924AbZAGL7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 06:59:32 -0500
Content-Disposition: inline
In-Reply-To: <20090107115605.GA29250@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 02:56:05PM +0300, Evgeniy Polyakov wrote:
>
> But it will not push pages into the stack, but copy them including copy
> of the submitted head?

It will use a single page entry for skb->head with splice, see
skb_splice_bits.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
