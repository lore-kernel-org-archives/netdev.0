From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 21:19:24 +1100
Message-ID: <20090119101924.GA1881@gondor.apana.org.au>
References: <20090119030844.GA31941@gondor.apana.org.au> <20090118.192719.198405397.davem@davemloft.net> <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55569 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758637AbZASKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:20:12 -0500
Content-Disposition: inline
In-Reply-To: <20090118.221908.47032075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 10:19:08PM -0800, David Miller wrote:
> 
> Actually, I see, the myri10ge driver does put up to
> 64 bytes of the initial packet into the linear area.
> If the IPV4 + TCP headers are less than this, you will
> hit the corruption case even with the myri10ge driver.

I thought splice only mapped the payload areas, no?

So we should probably test with a non-paged driver to be totally
sure.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
