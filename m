From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Sat, 21 Mar 2015 09:25:30 +1100
Message-ID: <20150320222530.GA24309@gondor.apana.org.au>
References: <20150320092703.GA17081@gondor.apana.org.au>
 <20150320095908.GG21258@acer.localdomain>
 <20150320101603.GA17662@gondor.apana.org.au>
 <20150320102701.GA28736@acer.localdomain>
 <20150320214712.GA23963@gondor.apana.org.au>
 <20150320215612.GA566@casper.infradead.org>
 <20150320215756.GA24045@gondor.apana.org.au>
 <20150320220751.GB566@casper.infradead.org>
 <20150320221021.GA24140@gondor.apana.org.au>
 <20150320222311.GC566@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40940 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbbCTWZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:25:38 -0400
Content-Disposition: inline
In-Reply-To: <20150320222311.GC566@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 10:23:11PM +0000, Thomas Graf wrote:
> 
> He might as well just run for (;;) to burn cycles in his namespace.
> If you give away virtualized local privileges you better be ready
> to restrict the resources consumed. 

Please reread the first email that you replied to, let me quote:

	A CPU intensive workload that can be rescheduled is
	completely different from one that is running under spin
	lock with BH disabled.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
