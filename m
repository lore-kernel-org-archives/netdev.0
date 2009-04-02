From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Thu, 2 Apr 2009 17:52:17 +0800
Message-ID: <20090402095217.GA30759@gondor.apana.org.au>
References: <49D3AD61.5090206@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, mingo@elte.hu, htejun@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	joe@perches.com, rusty@rustcorp.com.au
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58294 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757263AbZDBJw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:52:59 -0400
Content-Disposition: inline
In-Reply-To: <49D3AD61.5090206@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> 
> There's probably not a lot of value in this.  The Intel and AMD 
> optimisation guides tend to deprecate inc/dec in favour of using 
> add/sub, because the former can cause pipeline stalls due to its partial 
> flags update.

Is this still the case on the latest Intel CPUs?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
