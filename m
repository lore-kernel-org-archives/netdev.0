From: "Zsolt SZALAI" <zs.szalai@gmail.com>
Subject: Re: [IPSEC] confused about IPSEC_MANUAL_REQID_MAX
Date: Thu, 11 Sep 2008 10:22:10 +0200
Message-ID: <dffc28000809110122ke4cbef6j1800dd29fef1e5ad@mail.gmail.com>
References: <dffc28000809090400l9617cfejc2607c6b3767417@mail.gmail.com>
	 <E1Kdh4i-0005Om-Qc@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.184]:62282 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbYIKIWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 04:22:13 -0400
Received: by mu-out-0910.google.com with SMTP id g7so175225muf.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 01:22:10 -0700 (PDT)
In-Reply-To: <E1Kdh4i-0005Om-Qc@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

I would like to switch, but it would require much time to port our
code, that we don't have now.
I hope af_key wont be deleted from the kernel tree in the near future,
and then we will have time to migrate.

BR,
Szalai Zsolt



On Thu, Sep 11, 2008 at 9:58 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Zsolt SZALAI <zs.szalai@gmail.com> wrote:
>>
>> As XFRM allows, is it safe to increase this value or even bypass the
>> checking of the reqid beeing higher than that?
>
> Please stop using the af_key interface.  The part dealing with
> policies (which is the only place where reqids are generated) is
> just as unportable as xfrm.
>
> In any case changing an interface should be avoided unless there
> is a really good reason.  In this case I don't see any good reasons
> since you can instead switch to xfrm.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
