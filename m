From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] rhashtable: Allow local locks to be used and tested
Date: Thu, 13 Nov 2014 15:13:36 -0500 (EST)
Message-ID: <20141113.151336.2230020230447466056.davem@davemloft.net>
References: <20141113101025.GA3728@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933468AbaKMUNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:13:40 -0500
In-Reply-To: <20141113101025.GA3728@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Nov 2014 18:10:25 +0800

> This series moves mutex_is_held entirely under PROVE_LOCKING so
> there is zero foot print when we're not debugging.  More importantly
> it adds a parrent argument to mutex_is_held so that we can test
> local locks rather than global ones (e.g., per-namespace locks).

Series applied, thanks Herbert.
