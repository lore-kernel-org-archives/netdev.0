From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Wed, 26 Oct 2011 10:05:10 +0200
Message-ID: <1319616310.18883.16.camel@edumazet-laptop>
References: <1319526752.3834.12.camel@edumazet-laptop>
	 <20111025.193037.1312584002692004360.davem@davemloft.net>
	 <1319610874.18883.8.camel@edumazet-laptop>
	 <1319616054.11727.19.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62196 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab1JZIFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 04:05:18 -0400
Received: by wwe6 with SMTP id 6so2030401wwe.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 01:05:16 -0700 (PDT)
In-Reply-To: <1319616054.11727.19.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 octobre 2011 =C3=A0 10:00 +0200, Ben Hutchings a =C3=A9c=
rit :
> On Wed, 2011-10-26 at 08:34 +0200, Eric Dumazet wrote:
> > Le mardi 25 octobre 2011 =C3=A0 19:30 -0400, David Miller a =C3=A9c=
rit :
> >=20
> > > net/ipv4/ip_sockglue.c: In function =E2=80=98do_ip_setsockopt=E2=80=
=99:
> > > net/ipv4/ip_sockglue.c:523:29: error: =E2=80=98LOOPBACK4_IPV6=E2=80=
=99 undeclared (first use in this function)
> > > net/ipv4/ip_sockglue.c:523:29: note: each undeclared identifier i=
s reported only once for each function it appears in
> > >=20
> > > This fails because ip_sockglue.c guards the net/transp_v6.h heade=
r
> > > inclusion with a real CPP guard.
> >=20
> > Yep, it seems compiler was not able to perform optimisation of dead
> > code.
> [...]
>=20
> No, the compiler is just checking the code further than you wanted
> before optimising it away.
>=20

Well, I was not saying compiler was guilty here.

Dead code must be parsed and compiled too.
