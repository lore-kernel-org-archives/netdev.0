From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Thu, 21 Aug 2008 18:00:00 +1000
Message-ID: <20080821080000.GA1530@gondor.apana.org.au>
References: <20080821061024.GA721@gondor.apana.org.au> <20080821064941.GA2764@ff.dom.local> <20080821071634.GA1269@gondor.apana.org.au> <20080821.005250.117238212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36214 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754412AbYHUIAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 04:00:07 -0400
Content-Disposition: inline
In-Reply-To: <20080821.005250.117238212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:52:50AM -0700, David Miller wrote:
> 
> If I get a chance I'll work on this.  But to be honest given
> Linus's temperment right now we're only going to be able to
> merge one-liners to fix these kinds of problems and anything
> more serious is going to be for net-next-2.6 only.

Oh yeah we don't need this right away.  Jarek's patch should be
quite safe for the time being.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
