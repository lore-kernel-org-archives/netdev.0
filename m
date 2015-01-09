From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the list
Date: Fri, 9 Jan 2015 11:07:27 +0800
Message-ID: <CA+U0gVg=K+au1Cyw=rcjqybMXwT8qSoDie71czEt1aTBwKj=0A@mail.gmail.com>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <20150108111554.GA8720@gondor.apana.org.au> <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
 <20150109022752.GA15785@gondor.apana.org.au> <CA+U0gVgS7z601DZvL82EJfYGYb5XQExw9CbnPRpUeN32TWLF7w@mail.gmail.com>
 <20150109023421.GA16089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34856 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbbAIDHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:07:48 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so15697576pab.5
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 19:07:47 -0800 (PST)
In-Reply-To: <20150109023421.GA16089@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 10:34 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Jan 09, 2015 at 10:32:13AM +0800, Dennis Chen wrote:
>>
>> Thanks, would you pls give me an example of those drivers? I'll study
>> it further...
>
> There are no known drivers doing this currently since that would
> be a bug and they would be fixed quickly.  But if you look back
> in history virtio_net was doing this.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Is this the below patch you mentioned?
https://lkml.org/lkml/2014/7/23/134

-- 
Den
