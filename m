From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc5-mm1 -- inconsistent {in-softirq-W} -> {softirq-on-R} usage.
Date: Sun, 16 Dec 2007 11:10:11 +0800
Message-ID: <E1J3jtL-0000Kc-00@gondolin.me.apana.org.au>
References: <20071215031341.66dc0d05.akpm@linux-foundation.org>
Cc: miles.lane@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2436 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753899AbXLPDKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 22:10:24 -0500
In-Reply-To: <20071215031341.66dc0d05.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
> My suspicion is that you've hit bad breakage in networking and lockdep just
> isn't sufficiently robust to handle what it's being given.
> 
> Can you suggest a way in which others can reproduce this?

I can reproduce this now.  I suspect it's to do with the namespace
work.  I'll let you know when I have digged further.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
