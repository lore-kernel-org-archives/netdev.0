From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 08 Oct 2014 05:29:19 -0700
Message-ID: <1412771359.2295.42.camel@jtkirshe-mobl>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54346339.3000509@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZuBo3z96A1cTZcbp1XA9"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33676 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbaJHM3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 08:29:33 -0400
In-Reply-To: <54346339.3000509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZuBo3z96A1cTZcbp1XA9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 00:03 +0200, Daniel Borkmann wrote:
> On 10/07/2014 10:30 PM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Support skb->xmit_more in i40e is straightforward : we need to move
> > around i40e_maybe_stop_tx() call to correctly test netif_xmit_stopped()
> > before taking the decision to not kick the NIC.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> Jeff, feel free to drop the same version I've sent you yesterday
> directly since this here is already in patchwork ...
>=20
> Thanks, Eric!
>=20
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Done, I have dropped your patch for this patch.

--=-ZuBo3z96A1cTZcbp1XA9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNS4fAAoJEOVv75VaS+3O2usP/RPJriZGIvOlSV1oCGSQ3jhb
e/ayGCw1rhrbQONiD6JLf9aNzqo/JMQotyaJzdAb+5kDbL8K5TxPsiamN4EiD1Oo
8CW/eNKwC28tIsI2RjxCbben1hfGYuXeMsfDpdIcZosWH7FXB931WF++y9lrS8YE
+IzW5Isz/DP0KefmyCs6A394xn1na+K1hV9p1M4UBJgX450BhjBKIVqzk/tqwvCG
XvOtysw3coOjcaMAmMkA9wn57kOC6glJD5czop09Y8LZ5VFNL8/k1kJRu4FvSAi0
F5IC5IR76KMItMuMvXW8UEX6Koatpzz27MYX+VGZQd+UuabtZfnGn4X4s0MlkCFq
ObBZYD3Rbqmq8l3LAuHGXPKt6ddkfI+katB3EQvfvINhtGC8kJOiT7oxSd33/ADP
z7yrDNjyWY1pzA7QqPJHpm4JZ6oXAcli25JvI0oTDivC/roIaRJadEcAa2AEwvkf
pwaX0Kqy+Tgi/4jY7Gjfa6QNfXDux++gXQL4S8ML7HH8r1wWFC6FxUns4TjPRYCX
LfUY5b/T94HVFULZ7JviQViGpOB2a3H2z3MseOqpsI+xqnLfHBaUpXaCLD586P/p
M7ziLbejub+XktlYmPqv2xIG52Yi7zIs8xPrghxoRzuEv+5G8oik6Gpp92Enl5eG
nVai110G1igyb6A4LZsq
=WJmE
-----END PGP SIGNATURE-----

--=-ZuBo3z96A1cTZcbp1XA9--
