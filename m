From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable - Cap total number of entries to 2^31
Date: Thu, 27 Apr 2017 11:48:48 -0400 (EDT)
Message-ID: <20170427.114848.2138225925263382074.davem@davemloft.net>
References: <20170425141749.GD11322@breakpoint.cc>
        <20170425.104822.1395000926293799711.davem@davemloft.net>
        <20170427054451.GA529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031520AbdD0Psu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 11:48:50 -0400
In-Reply-To: <20170427054451.GA529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 27 Apr 2017 13:44:51 +0800

> When max_size is not set or if it set to a sufficiently large
> value, the nelems counter can overflow.  This would cause havoc
> with the automatic shrinking as it would then attempt to fit a
> huge number of entries into a tiny hash table.
> 
> This patch fixes this by adding max_elems to struct rhashtable
> to cap the number of elements.  This is set to 2^31 as nelems is
> not a precise count.  This is sufficiently smaller than UINT_MAX
> that it should be safe.
> 
> When max_size is set max_elems will be lowered to at most twice
> max_size as is the status quo.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next, thanks Herbert.
