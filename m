From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 15:17:47 +0800
Message-ID: <20100319071747.GB22809@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi> <20100319003130.GA20227@gondor.apana.org.au> <4BA31049.7030005@iki.fi> <20100319060322.GA22319@gondor.apana.org.au> <4BA317CE.4050503@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751021Ab0CSHRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 03:17:49 -0400
Content-Disposition: inline
In-Reply-To: <4BA317CE.4050503@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 08:21:02AM +0200, Timo Ter=E4s wrote:
>
>> Or have I misread your patch? You *are* proposing to cache the last
>> used bundle in the policy, right?
>
> Yes and no. The bundle used is cached on per-flow basis.
> The flow cache can have lot of entries each referring to
> same policy but separate bundle.

OK so I did misread your patch.

In fact it is already doing exactly what I was suggesting, I'll
review your patch again with this new insignt :)

> But keeping policy and bundle in cache is still a win. If we
> kill the xfrm_dst due to GC, we will also lose the policy
> the flow matched. We might need to kill xfrm_dst due to the
> inside dst going old, but the flow cache would still give
> hit with policy info (but no bundle) the next a packet comes
> in using the same flow.

We were in complete agreement all along :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
