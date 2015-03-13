From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: Fix potential crash in nft_hash walker
Date: Thu, 12 Mar 2015 23:05:32 -0400 (EDT)
Message-ID: <20150312.230532.1927015442497329615.davem@davemloft.net>
References: <20150312235214.GA26546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbCMDFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:05:34 -0400
In-Reply-To: <20150312235214.GA26546@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Mar 2015 10:52:14 +1100

> When we get back an EAGAIN from rhashtable_walk_next we were
> treating it as a valid object which obviously doesn't work too
> well.
>     
> Luckily this is hard to trigger so it seems nobody has run into
> it yet.
>     
> This patch fixes it by redoing the next call when we get an EAGAIN.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Pablo, you got this one?
