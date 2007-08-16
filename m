From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable and friendly ?
Date: Fri, 17 Aug 2007 07:33:39 +0800
Message-ID: <20070816233339.GA11594@gondor.apana.org.au>
References: <20070816153619.2c699e21.dada1@cosmosbay.com> <E1ILft1-0001Db-00@gondolin.me.apana.org.au> <20070816174044.43c90ff4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2977 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753030AbXHPXdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 19:33:47 -0400
Content-Disposition: inline
In-Reply-To: <20070816174044.43c90ff4.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 05:40:44PM +0200, Eric Dumazet wrote:
> 
> So do you think this patch is enough or should we convert dst_run_gc processing from softirq to workqueue too ?

I think a workqueue would be the best solution since with
that you wouldn't have to worry about processing things in
chunks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
