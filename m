From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFT] proxy arp deadlock possible
Date: Thu, 05 Apr 2007 10:44:41 +1000
Message-ID: <E1HZG5h-0001oF-00@gondolin.me.apana.org.au>
References: <20070404152635.7c3ba33e@localhost>
Cc: davej@redhat.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org (Stephen Hemminger),
	davem@davemloft.net, mingo@elte.hu, arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1026 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752864AbXDEApO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 20:45:14 -0400
In-Reply-To: <20070404152635.7c3ba33e@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Thanks Dave, there is a classic AB BA deadlock here.
> We should break the dependency like this.
> 
> Could someone who uses proxy ARP test this?

Sorry Stephen, this isn't necessary.  The lockdep thing is
simply confused here.  It's treating tbl->proxy_queue as the
same thing as neigh->arp_queue when they're clearly different.

I'm disappointed that after all this time lockdep is still
producing bogus reports like this.  I'm sure we've been
through this particular issue many times already.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
