From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] rhashtable: Handle table allocation failure during
 insertion
Date: Wed, 08 Feb 2017 13:26:42 -0500 (EST)
Message-ID: <20170208.132642.68242478649592606.davem@davemloft.net>
References: <20170207123827.GA14678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdBHS2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:28:15 -0500
In-Reply-To: <20170207123827.GA14678@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Feb 2017 20:38:27 +0800

> This series tackles the problem of table allocation failures during
> insertion.  The issue is that we cannot vmalloc during insertion.
> This series deals with this by introducing nested tables.
> 
> The first two patches removes manual hash table walks which cannot
> work on a nested table.
> 
> The final patch introduces nested tables.
> 
> I've tested this with test_rhashtable and it appears to work.

rhashtable is indeed getting quite complex, but I understand your
motivation for doing this work.

I also agree that only true OOM situations should cause insertion
failures.

Given the delicate nature of change rhashtable this way, I'm going
to let these changes sit for a couple days before applying them.

Thanks Herbert.
