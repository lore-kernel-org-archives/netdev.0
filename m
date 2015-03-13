From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Thu, 12 Mar 2015 23:01:42 -0400 (EDT)
Message-ID: <20150312.230142.925554248034420272.davem@davemloft.net>
References: <20150312110749.GA19285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbbCMDBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:01:44 -0400
In-Reply-To: <20150312110749.GA19285@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 Mar 2015 22:07:49 +1100

> There is a potential race condition between readers and the rehasher.
> In particular, the rehasher could have started a rehash while the
> reader finishes a scan of the old table but fails to see the new
> table pointer.
> 
> This patch closes this window by adding smp_wmb/smp_rmb.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
