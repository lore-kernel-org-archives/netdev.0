From: David Miller <davem@davemloft.net>
Subject: Re: [rhashtable] 5d60de5ff1 [ INFO: suspicious RCU usage. ]
Date: Sun, 26 Feb 2017 21:34:31 -0500 (EST)
Message-ID: <20170226.213431.1259588475180135466.davem@davemloft.net>
References: <20170218052331.dlr4si7gbhnukewb@wfg-t540p.sh.intel.com>
        <20170225143950.GB28272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, lkp@01.org, netdev@vger.kernel.org,
        tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdB0Cep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:34:45 -0500
In-Reply-To: <20170225143950.GB28272@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 25 Feb 2017 22:39:50 +0800

> Subject: rhashtable: Fix RCU dereference annotation in rht_bucket_nested
> 
> The current annotation is wrong as it says that we're only called
> under spinlock.  In fact it should be marked as under either
> spinlock or RCU read lock.
> 
> Fixes: da20420f83ea ("rhashtable: Add nested tables")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
