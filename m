From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 23:29:51 +0800
Message-ID: <20090703152951.GA28837@gondor.apana.org.au>
References: <20090703140401.GA10256@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, jolsa@redhat.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, eric.dumazet@gmail.com,
	Paul.McKenney@us.ibm.com
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56476 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754747AbZGCPaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 11:30:09 -0400
Content-Disposition: inline
In-Reply-To: <20090703140401.GA10256@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> 
> Why don't we create a read_lock without acquire semantic instead (e.g.
> read_lock_nomb(), or something with a better name like __read_lock()) ?
> On architectures where memory barriers are needed to provide the acquire
> semantic, it would be faster to do :
> 
> __read_lock();
> smp_mb();
> 
> than :
> 
> read_lock(); <- e.g. lwsync + isync or something like that
> smp_mb(); <- full sync.

Hmm, why do we even care when read_lock should just die?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
