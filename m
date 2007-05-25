From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently when reading from certain proc file entries
Date: Fri, 25 May 2007 17:17:19 +1000
Message-ID: <20070525071719.GA26815@gondor.apana.org.au>
References: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au> <4656872C.9000701@cosmosbay.com> <20070525065712.GA26619@gondor.apana.org.au> <46568D05.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	andsve@gmail.com
To: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750769AbXEYHRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 03:17:52 -0400
Content-Disposition: inline
In-Reply-To: <46568D05.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 25, 2007 at 09:15:17AM +0200, Eric Dumazet wrote:
> 
> I am very glad you fixed /proc/net/tcp, but I would like to
> understand why this cond_resched_softirq() even exist.

Well presumably it lets other threads have a chance to run in
a BH-disabled section.

> Its name and behavior dont match at all.

But yes it probably makes sense for it to process some softirq
work as well.  Ingo?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
