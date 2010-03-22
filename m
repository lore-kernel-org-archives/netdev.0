From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Mon, 22 Mar 2010 09:40:10 +0800
Message-ID: <20100322014010.GA14182@gondor.apana.org.au>
References: <20100320151751.GB2950@gondor.apana.org.au> <20100321.182846.232914131.davem@davemloft.net> <20100322013257.GA14080@gondor.apana.org.au> <20100321.183656.173864141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41520 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753898Ab0CVBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:40:19 -0400
Content-Disposition: inline
In-Reply-To: <20100321.183656.173864141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 06:36:56PM -0700, David Miller wrote:
>
> And as a consequence, making the xfrm_dst's be per-cpu would mess with
> route metrics for TCP.

Actually xfrm_dst currently relies on IPv4 rt objects to maintain
the metrics.  So as long as IPv4 routes are still global, then the
metrics won't be affected as far as can I see.

Did I miss something?

> I'm willing to consider this seriously, to be honest.

I would consider that too.  But right now I'm just looking for
the bare minimum to solve the problem at hand :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
