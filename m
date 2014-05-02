From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Fri, 02 May 2014 17:21:24 +0100
Message-ID: <1399047684.24523.11.camel@deadeye.wl.decadent.org.uk>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	 <1398969880-8007-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SGaFWvmTNgPlQlu9V2dY"
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59806 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752635AbaEBQVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 12:21:45 -0400
In-Reply-To: <1398969880-8007-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SGaFWvmTNgPlQlu9V2dY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-05-01 at 11:44 -0700, Chema Gonzalez wrote:
> Patch adds an ANC_TRA_OFFSET insn that loads the internal transport
> header of a packet ("internal" meaning after decapsulation by the
> flow dissector).
[...]

This turns the behaviour of the flow dissector into a userland ABI,
which must then be stable.  Is it ready for that?

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-SGaFWvmTNgPlQlu9V2dY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU2PGEOe/yOyVhhEJAQqfVQ/8D2MnzDf+C8N6VdarpY+H+54DWFQB3SBI
CLTna4HBO3hLYgqGr9tROT4JTdkldf4zKhP2mzkelSmDpt1g/ZgHa1SMgO/5T0zV
D8IELT4c5rndq+z0NKR2yPh0n20sYEgYI+Y08cQHLxfreyOy1+Lo/XkMVCuTIoQT
clgvdP6NwuuYpFQJ2VdqffNxWUqlPD7zteFNy3Q5OLbgxh02qjDdG6gL2Q40cs0C
T7o4sjMN/6YJBCYNKXp0KPWHd3oh0oLzcp79fErqkuBr67b7RegTQQjxIt0X1FWr
nDhhuRwO6RRQzHp25GoFkhe51DOcMw2rXv/leqFc7IWQ8UZ/CjDTukY/jaiqSEet
+81pmnVh3pVtXVtOMh/QEjzrdKqAJXNxIK+o1Q5gn4hPyL6BQlwa37zjp2B4nutd
uZ23x57C+0n0csXdRN03J0GDYXq63ybT5hbPC4qvDlz0Kp7qjP/9K7vZtFU4JuP2
jGQRFmHqf3loh9Nfl+dDd9GS4o0sj3jMsaVaHa1ZXIRQuhbabVI0KPxUpFTUIWwi
z/H7vLOMOnPEjSkpTgUicShyfpnqCfh7JgKyJHcCWwxw27c5Pnb9dEOOYwd9cc0f
chbPM9Yg3w0Feif4bJDNGycGDZDsC+BNYE6x+HD5zp0A4vw3UXXH6Mf8ozesTGXz
DXSX/4D5Lto=
=uzHY
-----END PGP SIGNATURE-----

--=-SGaFWvmTNgPlQlu9V2dY--
