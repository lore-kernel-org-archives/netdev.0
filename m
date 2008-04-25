From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: alg_key_len & alg_icv_len should be unsigned
Date: Fri, 25 Apr 2008 00:29:42 -0700 (PDT)
Message-ID: <20080425.002942.44065218.davem@davemloft.net>
References: <48118391.3010109@cosmosbay.com>
	<20080425071419.GA17997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755825AbYDYH3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:29:43 -0400
In-Reply-To: <20080425071419.GA17997@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Apr 2008 15:14:20 +0800

> On Fri, Apr 25, 2008 at 09:09:05AM +0200, Eric Dumazet wrote:
> > In commit ba749ae98d5aa9d2ce9a7facde0deed454f92230 ([XFRM]: alg_key_len 
> > should be unsigned to avoid integer divides 
> > <http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=ba749ae98d5aa9d2ce9a7facde0deed454f92230>) 
> > alg_key_len field of struct xfrm_algo was converted to unsigned int to 
> > avoid integer divides.
> > 
> > Then Herbert in commit 1a6509d991225ad210de54c63314fd9542922095 
> > ([IPSEC]: Add support for combined mode algorithms) added a new 
> > structure xfrm_algo_aead, that resurrected a signed int for alg_key_len 
> > and re-introduce integer divides.
> > 
> > This patch avoids these divides and saves 64 bytes of text on i386.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I actually wrote my patch before yours was merged which was why
> it was signed.

Applied, thanks everyone.
