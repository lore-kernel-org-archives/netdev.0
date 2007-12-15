From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 14:10:21 +0800
Message-ID: <20071215061021.GA26247@gondor.apana.org.au>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org> <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2551 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750729AbXLOGK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 01:10:28 -0500
Content-Disposition: inline
In-Reply-To: <20071214214418.0ecd5e67.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 09:44:18PM -0800, Andrew Morton wrote:
>
> That sounds like a bug in mutex_trylock() to me.

I was relying on

	http://kerneltrap.org/mailarchive/linux-netdev/2007/9/28/325129

which seems to be a bogus claim now that I actually look at the
source code.  So in that case I'm OK with your patch as long as
it warns about hard IRQ usage.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
