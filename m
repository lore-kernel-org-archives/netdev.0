From: David Miller <davem@davemloft.net>
Subject: Re: another networking lockdep trace.
Date: Wed, 09 Aug 2006 16:52:22 -0700 (PDT)
Message-ID: <20060809.165222.32095748.davem@davemloft.net>
References: <20060808184157.GB4880@redhat.com>
	<E1GAmbn-0006Ts-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	mingo@elte.hu, arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31189
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751330AbWHIXwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:52:34 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1GAmbn-0006Ts-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 09 Aug 2006 21:52:23 +1000

> Nice.  This is a bug introduced less than 2 weeks ago.  We're finally
> getting some dividends from the lock validator :) Thanks guys!

Horray! :-)

> [IPV6]: The ifa lock is a BH lock
> 
> The ifa lock is expected to be taken in BH context (by addrconf timers)
> so we must disable BH when accessing it from user context.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
