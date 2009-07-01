From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Wed, 1 Jul 2009 11:39:24 +0800
Message-ID: <20090701033924.GA29762@gondor.apana.org.au>
References: <87eit3l7y6.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jolsa@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60572 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755349AbZGADjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 23:39:25 -0400
Content-Disposition: inline
In-Reply-To: <87eit3l7y6.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:
> 
> At least on x86 I can't see how it happens. mb() is only a compile
> time barrier and the compiler doesn't optimize over indirect callbacks
> like __pollwait() anyways.

mb() does more than just a compiler barrier, it also issues mfence.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
