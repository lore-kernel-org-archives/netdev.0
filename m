From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2 net-next] ixgbe: use skb_padto
Date: Mon, 18 Jun 2012 13:38:47 -0700
Message-ID: <1340051927.1995.32.camel@jtkirshe-mobl>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-COccLVCOp3uUFnEefRsL"
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31164 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab2FRUiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 16:38:54 -0400
In-Reply-To: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-COccLVCOp3uUFnEefRsL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-06-18 at 10:58 -0700, Stephen Hemminger wrote:
> The code to pad packets here is the same effective code as
> the existing inline function skb_padto(). There is a minor
> performance gain since skb_padto() also uses unlikely().
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>=20

Thanks Stephen, I have added it to my queue.

--=-COccLVCOp3uUFnEefRsL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP35HXAAoJEOVv75VaS+3OQ0EP/06RSZ+ATmUx2tWUJUhUH+5/
7CU2b9cQKOC+zShBP6r+fTmsUw6qpzbZxSWHzuIyXbucLvTY+S33h0IEgVjXD7Ei
Jjph+U2YQHjkkkcvnxWZc6KZCR0kJjPTmGrRH/0xpmm9Kxs6JmSb66SNBPN3xYUZ
dhtKVrDU5snwDFU8zpQ7UZyfLB1afZd6Sx66MNMLeeTlyrnG5y5oIgZ3xHyruezE
GLUXnL2TLrnX6/e++Vo4dGZ9A2cb+prsbHbhyQgh4gii0mx4INmKlRvfl53PWceu
m7HPr2F6SjqPhNF/eAvOgZcPWvS33i26IZMutP8KiwbOGLjpdUTYhH5zbIc9hKbp
RUrOBk9LKjO96Y0q8TxL1doASjGb8vAhc5biL0MVAgFdGKr17HTAPfeR+Z+FhlhI
kc1I0Wgi8mcrp4rzy6viEeIAeh0tqli2ds/MkApBIEhbQiLorwvk4OfdrA++MuWK
pK14yd4umZvH87qS44eytMBaj8D/3409f21SpLT5FrenyvVi+K9jWh1Kq2qVbgmS
as8jVkzc0YPiCu2OZZqveECGc3ljQTq6QkesffeNasmsf5n0Juj5G/RtYDrVAAEU
jH3oh3r7pElE7wsP/IybmbLn6a1iAMt+nO8BI9HGLQFTHkxQ4oulA3/dK3hpC8BH
URk1tzg7vJMCvEbYq+QB
=orMK
-----END PGP SIGNATURE-----

--=-COccLVCOp3uUFnEefRsL--
