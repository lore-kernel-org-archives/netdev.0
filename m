From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 5/7] rhashtable: abstract out function to get hash
Date: Tue, 20 Sep 2016 20:17:43 -0700
Message-ID: <CALx6S35K5BcMeVtgVZXJNYT51Lho7ZT4xY5ZU5mhYVC9vUwzfQ@mail.gmail.com>
References: <1473895376-347096-6-git-send-email-tom@herbertland.com>
 <20160920093659.GA20975@gondor.apana.org.au> <20160920175803.GE3291@pox.localdomain>
 <20160921024613.GA27473@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33974 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753528AbcIUDRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 23:17:44 -0400
Received: by mail-qk0-f196.google.com with SMTP id b204so2328697qkc.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 20:17:43 -0700 (PDT)
In-Reply-To: <20160921024613.GA27473@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 7:46 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Sep 20, 2016 at 07:58:03PM +0200, Thomas Graf wrote:
>>
>> I understand this particular patch as an effort not to duplicate
>> hash function selection such as jhash vs jhash2 based on key_len.
>
> If the rhashtable params stay non-const as is then this is going
> to produce some monstrous code which will be worse than using
> jhash unconditionally.
>
I will look at keep params constant.

Tom

> If the rhashtable params are made const then you'll already know
> whether jhash or jhash2 is used.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
