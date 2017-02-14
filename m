From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 0/3] rhashtable: Handle table allocation failure
 during insertion
Date: Mon, 13 Feb 2017 22:18:03 -0500 (EST)
Message-ID: <20170213.221803.562953348958596767.davem@davemloft.net>
References: <20170207123827.GA14678@gondor.apana.org.au>
        <20170211112421.GA1570@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdBNDSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 22:18:11 -0500
In-Reply-To: <20170211112421.GA1570@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 11 Feb 2017 19:24:22 +0800

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

Series applied, thanks Herbert.
