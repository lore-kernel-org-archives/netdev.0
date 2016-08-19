From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] rhashtable: Get rid of raw table walkers part 1
Date: Fri, 19 Aug 2016 14:40:51 -0700 (PDT)
Message-ID: <20160819.144051.306029724958680678.davem@davemloft.net>
References: <20160818084854.GA11502@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754043AbcHSVkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 17:40:52 -0400
In-Reply-To: <20160818084854.GA11502@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Aug 2016 16:48:54 +0800

> This series starts the process of getting rid of all raw rhashtable
> walkers (e.g., using any of the rht_for_each helpers) from the
> kernel.
> 
> We need to do this before I can fix the resize kmalloc failure issue
> by using multi-layered tables.
> 
> We should do this anyway because almost all raw table walkers are
> already buggy in that they don't handle multiple rhashtables during
> a resize.

Series applied to net-next with v2 of patch #3.

> Dave/Tomas, please keep an eye out for any new patches that try
> to introduce raw table walkers and nack them.

Ok.
