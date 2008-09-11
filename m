From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] confused about IPSEC_MANUAL_REQID_MAX
Date: Thu, 11 Sep 2008 17:58:48 +1000
Message-ID: <E1Kdh4i-0005Om-Qc@gondolin.me.apana.org.au>
References: <dffc28000809090400l9617cfejc2607c6b3767417@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: zs.szalai@gmail.com (Zsolt SZALAI)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38578 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751876AbYIKH6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 03:58:52 -0400
In-Reply-To: <dffc28000809090400l9617cfejc2607c6b3767417@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zsolt SZALAI <zs.szalai@gmail.com> wrote:
>
> As XFRM allows, is it safe to increase this value or even bypass the
> checking of the reqid beeing higher than that?

Please stop using the af_key interface.  The part dealing with
policies (which is the only place where reqids are generated) is
just as unportable as xfrm.

In any case changing an interface should be avoided unless there
is a really good reason.  In this case I don't see any good reasons
since you can instead switch to xfrm.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
