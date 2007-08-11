From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Sat, 11 Aug 2007 08:54:46 +0800
Message-ID: <E1IJfFe-0003Sq-00@gondolin.me.apana.org.au>
References: <46BCC26B.6080600@redhat.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: csnook@redhat.com (Chris Snook)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1518 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756714AbXHKAzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:55:10 -0400
In-Reply-To: <46BCC26B.6080600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> wrote:
> 
> cpu_relax() contains a barrier, so it should do the right thing.  For 
> non-smp architectures, I'm concerned about interacting with interrupt 
> handlers.  Some drivers do use atomic_* operations.

What problems with interrupt handlers? Access to int/long must
be atomic or we're in big trouble anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
