From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.0-longterm] bonding: ARP packet fix for balance-ALB
 (mode=6)
Date: Mon, 01 Apr 2013 19:14:21 +0100
Message-ID: <1364840061.3557.109.camel@deadeye.wl.decadent.org.uk>
References: <CAK8PzVnNfLSnvxY83z3Em3gtJM4zWM0Xd4P3CWy3xt=7feJgMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fN6TSAJ+50OqF4MNi+EA"
Cc: netdev@vger.kernel.org
To: Matthew O'Connor <liquidhorse@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52747 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757204Ab3DASOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 14:14:36 -0400
In-Reply-To: <CAK8PzVnNfLSnvxY83z3Em3gtJM4zWM0Xd4P3CWy3xt=7feJgMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fN6TSAJ+50OqF4MNi+EA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-04-01 at 12:36 -0400, Matthew O'Connor wrote:
> Do not modify or load balance ARP packets passing through balance-alb
> mode (wherein the ARP did not originate locally, and arrived via a bridge=
).
>=20
> This patch is backported from the upstream commit:
>     From 567b871e503316b0927e54a3d7c86d50b722d955 Mon Sep 17 00:00:00 200=
1
>     Subject: [PATCH] bonding: rlb mode of bond should not alter ARP
> originating via bridge
>=20
> Signed-off-by:  Matthew O'Connor <liquidhorse@gmail.com>
[...]

These patches are tab-damaged and word-wrapped.  See
Documentation/email-clients.txt

You should also use the conventional format for backported patches.
Keep the original commit message, but above it add:

    From: original author <address@domain>

    commit 567b871e503316b0927e54a3d7c86d50b722d955 upstream.

The commit reference could also be written in David Miller's favoured
format:

    [ Upstream commit 567b871e503316b0927e54a3d7c86d50b722d955 ]

If you have made substantial changes then explain them at the end of the
commit message with clear attribution to yourself.  You could add some
explanation below the '---' of why this is important to include in a
stable update.

Lastly, this should be cc'd to all the addresses on the original commit
(From, Cc, and Signed-off-by).

Ben.

--=20
Ben Hutchings
DNRC Motto:  I can please only one person per day.
Today is not your day.  Tomorrow isn't looking good either.

--=-fN6TSAJ+50OqF4MNi+EA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUVnOfee/yOyVhhEJAQoZ8BAAtEFiUqcJtmzTiE2uQho4Pf9WleEef+Wr
LAsnv13wyfetBsRa/Nl8QYYmn2JMMdx2E07CEczYw9IbsFxmFRw5eqZttTkc8j3e
JMoOeBoBpb7dKPgWY3C5yZ4IB0eN4wRMT+mrKcQl5c3LQ1FKw3nycvdZZh9MChbm
1kuSK8sSB3vI4jchpdl0LknGFRFaJdIc3SjCPZRpBjTM8l8rW0QQ/8+qhprrNA3j
ubDdjabhWl7rcAYZEld3WsHV8q35gLm74k7//OodmDWkh3/cL+VMV/CoD3q48HMe
LrJhcQPxWCk4/IA+qlgm9BFA4xDRkoTfSx9OXPg2A5i4/krpoL0fLfEi1o9e2911
2p25zIRI8/pAdeEMxJWshlT25kyhGJ1yIayeVU0PK3stQ+9bIlXg679KHwYeTJyd
M16bWRvXy38zreouH6xiBABIvdJsmgZ1q2x/FlMltiqB63XM22Cxsrfy+BL3jHQa
F8ZBgzu8c7g+w+jLh5pu8sRFPiyhOQi16E5Qm3rmksMKf0MFetQ3fHwjpFoHCLrC
0z4E45BY4yCFHxHq19WabLRPs14NjQc/RO5tu85eQ0hmJ6NWXjl/aKiFEnVks67l
gavAwoj2WlSSOxr0oeqls90ZqMnnfMixwu1sRTUPLoisE4vZLAAWo7OSHmLEeRPG
T6PVIB7eObA=
=7PiF
-----END PGP SIGNATURE-----

--=-fN6TSAJ+50OqF4MNi+EA--
