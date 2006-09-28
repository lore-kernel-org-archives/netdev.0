From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Thu, 28 Sep 2006 10:38:29 +1000
Message-ID: <20060928003829.GA8952@gondor.apana.org.au>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6150 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1031290AbWI1Aio
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 20:38:44 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20060926112122.GU22330@ripe.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2006 at 01:21:22PM +0200, cagri coltekin wrote:
>
> ------------------------------------------------------------------------------
> [ 1395.890897] ------------[ cut here ]------------
> [ 1395.946093] kernel BUG at net/ipv6/ip6_output.c:940!

Could you go further back in the logs to see if there was a
warning message? Either that or turn the WARN_ON into a BUG.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
