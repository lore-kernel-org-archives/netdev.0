From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Tue, 28 Sep 2010 10:48:58 +0200
Message-ID: <1285663738.2607.30.camel@edumazet-laptop>
References: <20100928084139.GA26793@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46212 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab0I1ItE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 04:49:04 -0400
Received: by fxm3 with SMTP id 3so2436063fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 01:49:02 -0700 (PDT)
In-Reply-To: <20100928084139.GA26793@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 17:41 +0900, Herbert Xu a =C3=A9crit =
:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > ipv6 can be a module, we should test CONFIG_IPV6 and CONFIG_IPV6_MO=
DULE
> > to enable ipv6 bits in ip_gre.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> To do this safely, we also need to disallow IPV6=3Dm and GRE=3Dy.
>=20
> Cheers,

Hmm you are right, I'll cook a patch.

Thanks


