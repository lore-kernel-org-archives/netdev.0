From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 12:18:27 +0800
Message-ID: <20071215041827.GC25324@gondor.apana.org.au>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org> <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1708 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752192AbXLOESe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 23:18:34 -0500
Content-Disposition: inline
In-Reply-To: <20071214151136.ae0f969b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 03:11:36PM -0800, Andrew Morton wrote:
>
> I don't believe that ASSERT_RTNL() presently warns when called from atomic
> contexts.  If it does then I missed it.

It does when mutex debugging is enabled.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
