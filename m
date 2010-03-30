From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/7] flow: allocate hash table for online cpus only
Date: Tue, 30 Mar 2010 20:12:55 +0800
Message-ID: <20100330121255.GC5731@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-4-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756492Ab0C3MM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:12:58 -0400
Content-Disposition: inline
In-Reply-To: <1269871964-5412-4-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 05:12:40PM +0300, Timo Teras wrote:
> Instead of unconditionally allocating hash table for all possible
> cpu's, allocate it only for online cpu's and release related
> memory if cpu goes down.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Hmm that's where we started but then Rusty changed it back in 2004:

commit 0a32dc4d8e83c48f7535d66731eb35d1916b39a8
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Wed Jan 21 18:14:37 2004 -0800

    [NET]: Simplify net/flow.c per-cpu handling.

    The cpu handling in net/core/flow.c is complex: it tries to allocate
    flow cache as each CPU comes up.  It might as well allocate them for
    each possible CPU at boot.

So I'd like to hear his opinion on changing it back again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
