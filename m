From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Wed, 26 Oct 2011 10:00:54 +0200
Message-ID: <1319616054.11727.19.camel@deadeye>
References: <1319526752.3834.12.camel@edumazet-laptop>
	 <20111025.193037.1312584002692004360.davem@davemloft.net>
	 <1319610874.18883.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31666 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790Ab1JZIBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 04:01:04 -0400
In-Reply-To: <1319610874.18883.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-26 at 08:34 +0200, Eric Dumazet wrote:
> Le mardi 25 octobre 2011 =C3=A0 19:30 -0400, David Miller a =C3=A9cri=
t :
>=20
> > net/ipv4/ip_sockglue.c: In function =E2=80=98do_ip_setsockopt=E2=80=
=99:
> > net/ipv4/ip_sockglue.c:523:29: error: =E2=80=98LOOPBACK4_IPV6=E2=80=
=99 undeclared (first use in this function)
> > net/ipv4/ip_sockglue.c:523:29: note: each undeclared identifier is =
reported only once for each function it appears in
> >=20
> > This fails because ip_sockglue.c guards the net/transp_v6.h header
> > inclusion with a real CPP guard.
>=20
> Yep, it seems compiler was not able to perform optimisation of dead
> code.
[...]

No, the compiler is just checking the code further than you wanted
before optimising it away.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
