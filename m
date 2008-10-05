From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity is exceeded
Date: Sun, 05 Oct 2008 11:26:47 +0800
Message-ID: <E1KmKGd-000393-UD@gondolin.me.apana.org.au>
References: <20080930.070804.26007839.davem@davemloft.net>
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, whydna@whydna.net
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32768 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752619AbYJED04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 23:26:56 -0400
In-Reply-To: <20080930.070804.26007839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> The idea is that we can by default not rebuild the secret
> at all.

Actually Andrew Dickson <whydna@whydna.net> came up with this idea
quite a while ago: Keep the rehash interval but do nothing until
some chain hits a specified length.  This is quite similar to
what is being discussed here.

Andrew, could you post the patch please?

In addition to this, we should probably enforce that limit as
well by simply not adding the newly created entry or deleting
one forcibly.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
