From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 14:49:03 +0800
Message-ID: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
References: <46C2350A.1010807@redhat.com>
Cc: satyam@infradead.org, clameter@sgi.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: csnook@redhat.com (Chris Snook)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2482 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750824AbXHOGu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 02:50:28 -0400
In-Reply-To: <46C2350A.1010807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> wrote:
> 
> Because atomic operations are generally used for synchronization, which requires 
> volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
>  Some forget to and we get bugs, because people assume that atomic_read() 
> actually reads something, and atomic_write() actually writes something.  Worse, 
> these are architecture-specific, even compiler version-specific bugs that are 
> often difficult to track down.

I'm yet to see a single example from the current tree where
this patch series is the correct solution.  So far the only
example has been a buggy piece of code which has since been
fixed with a cpu_relax.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
