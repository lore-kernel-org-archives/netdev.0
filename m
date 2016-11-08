From: Xin Long <lucien.xin@gmail.com>
Subject: Re: rhashtable: how to use insecure_elasticity of rhashtable_params
Date: Tue, 8 Nov 2016 16:42:15 +0800
Message-ID: <CADvbK_dqPzJRx__atT1idDrsyyJPYJfNC8UNZbw=N93Ra_AV5g@mail.gmail.com>
References: <CADvbK_cPQVT-icKn_2WpKqTyWgVEJikSAbg6=xB3+dt=zcdk0Q@mail.gmail.com>
 <20161107075545.GB26538@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        Phil Sutter <phil@nwl.cc>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35087 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbcKHImz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 03:42:55 -0500
Received: by mail-qt0-f174.google.com with SMTP id c47so103020667qtc.2
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 00:42:16 -0800 (PST)
In-Reply-To: <20161107075545.GB26538@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2016 at 3:55 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sun, Nov 06, 2016 at 09:15:07PM +0800, Xin Long wrote:
>> Now when I don't set  insecure_elasticity, ht->elasticity would be
>> set 16, it would be checked in  the loop of __rhashtable_insert_fast
>> and rhashtable_lookup_one.
>
> This is now obsolete.  Please use the new rhlist interface.
>
just checked, It's a very new interface.
will try it, thanks.

> Thanks,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
