From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 08:24:03 +0200
Message-ID: <1285741443.22570.27.camel@edumazet-laptop>
References: <20100928084139.GA26793@gondor.apana.org.au>
	 <1285663738.2607.30.camel@edumazet-laptop>
	 <1285733911.22570.20.camel@edumazet-laptop>
	 <1285734295.22570.25.camel@edumazet-laptop>
	 <20100929043642.GA3660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56370 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab0I2GYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 02:24:09 -0400
Received: by fxm14 with SMTP id 14so263950fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 23:24:08 -0700 (PDT)
In-Reply-To: <20100929043642.GA3660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 13:36 +0900, Herbert Xu a =C3=A9cr=
it :
> On Wed, Sep 29, 2010 at 06:24:55AM +0200, Eric Dumazet wrote:
> >
> > Well, we all know icmpv6_cleanup() is not really called (or can we
> > really unload ipv6 ?).
> >=20
> > But unregister_icmpv6_send() should be the first call in it.
>=20
> Do we really need to support IPV6=3Dm and GRE=3Dy? It might be simple=
r
> to just behave as if IPv6 is off when this combination is given.
>=20
> Cheers,

Well, sometimes people wants to :

/etc/modprobe.conf
install ipv6 /bin/true


Yet, be able to load ip_gre as a module

so IPV6=3Dm, GRE=3Dm,



