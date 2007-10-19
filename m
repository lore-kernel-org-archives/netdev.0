From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] net: Let inet_diag and friends autoload
Date: Fri, 19 Oct 2007 16:21:23 +0800
Message-ID: <E1Iin6h-000367-00@gondolin.me.apana.org.au>
References: <20071017.195125.15264659.davem@davemloft.net>
Cc: jdelvare@suse.de, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1054 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754442AbXJSIVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 04:21:46 -0400
In-Reply-To: <20071017.195125.15264659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> I'm concerned it might be dangerous to load the module in
> this context, the RTNL semaphore is held and the module we
> are requesting could easily try to take it and deadlock.

We shouldn't be holding the RTNL here.  AFAICS we only hold
inet_diag_mutex which is used in just one spot.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
