From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity is exceeded
Date: Sun, 05 Oct 2008 11:17:27 +0800
Message-ID: <E1KmK7b-00036t-LM@gondolin.me.apana.org.au>
References: <20080929191254.GA20074@hmsreliant.think-freely.org>
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, nhorman@tuxdriver.com
To: nhorman@tuxdriver.com (Neil Horman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44138 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752619AbYJEDRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 23:17:35 -0400
In-Reply-To: <20080929191254.GA20074@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:
>        We currently have the ability to disable our route cache secret interval
> rebuild timer (by setting it to zero), but if we do that its possible for an
> attacker (if they guess our route cache hash secret, to fill our system with
> routes that all hash to the same bucket, destroying our performance.  This patch

This is completely bogus.  We never allow any chain to grow beyond
the elasticity.  So in the worst case we just bypass the route cache.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
