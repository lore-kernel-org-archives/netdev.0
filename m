From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 21:20:11 +1100
Message-ID: <20090119102011.GB1881@gondor.apana.org.au>
References: <20090115.152608.89323697.davem@davemloft.net> <20090115233205.GA8474@gondor.apana.org.au> <20090115.153449.204259387.davem@davemloft.net> <20090118.221603.177818343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37910 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759819AbZASKUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:20:41 -0500
Content-Disposition: inline
In-Reply-To: <20090118.221603.177818343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 10:16:03PM -0800, David Miller wrote:
> 
> Actually, Herbert, it turns out this case should be OK.
> 
> Look a level or two higher, at __splice_segment(), it even has a
> comment :-)

Aha, that should take care of it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
