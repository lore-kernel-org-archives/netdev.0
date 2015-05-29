From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Fri, 29 May 2015 08:24:20 +0800
Message-ID: <20150529002420.GA14942@gondor.apana.org.au>
References: <20150528135044.GA8313@gondor.apana.org.au>
 <1432823901.7456.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44124 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbE2AYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 20:24:25 -0400
Content-Disposition: inline
In-Reply-To: <1432823901.7456.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 07:38:21AM -0700, Eric Dumazet wrote:
>
> A = B;  is perfectly fine since both A and B have the same __rcu
> attribute.
> 
> Sparse has no warning and should not.
> 
> root@edumazet-glaptop2:/usr/src/net# grep CONFIG_SPARSE_RCU_POINTER .config
> CONFIG_SPARSE_RCU_POINTER=y
> root@edumazet-glaptop2:/usr/src/net# make C=2 CF=-D__CHECK_ENDIAN__ net/core/neighbour.o
> ...
>   CHECK   net/core/neighbour.c

Indeed.  Thanks for pointing this out.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
