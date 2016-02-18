From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V4
Date: Thu, 18 Feb 2016 01:15:01 -0800
Message-ID: <1455786901.3128.13.camel@intel.com>
References: <56C506FD.5040408@gmail.com>
	 <20160217.212910.1758016077144502307.davem@davemloft.net>
	 <97579B9E-E7C6-4DBE-B1A2-027C2EA7F754@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ROvRVFBr24mAnx70Vv/c"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: John Holland <jotihojr@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2212 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425593AbcBRJPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:15:03 -0500
In-Reply-To: <97579B9E-E7C6-4DBE-B1A2-027C2EA7F754@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ROvRVFBr24mAnx70Vv/c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-18 at 08:53 +0100, John Holland wrote:
>=20
> > On Feb 18, 2016, at 03:29, David Miller <davem@davemloft.net>
> wrote:
> >=C2=A0
> > From: John Holland <jotihojr@gmail.com>
> > Date: Thu, 18 Feb 2016 00:49:17 +0100
> >=C2=A0
> >> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an
> OTP
> >> and has no externel EEPROM interface [1]. The following allows the
> >> driver to pickup the MAC address from a device tree blob when
> >> CONFIG_OF
> >> has been enabled.
> >=C2=A0
> > Please use the generic eth_platform_get_mac_address(), or
> > alternatively structure your code like the ixgbe and other cases so
> > that SPARC and other OF platforms get this support as well.
>=20
> Don't know what you mean. The PCI path in
> eth_platform_get_mac_address() didn't return a devicetree node and I
> can find no instance of of_<function> use in ixgbe.

See commit=C2=A0e1be080f292eba2ef96af999057d1603cd50b473 in my dev-queue
branch. =C2=A0Sowmini Varadhan provided a patch to
use=C2=A0eth_platform_get_mac_address() instead of the "CONFIG_SPARC"
solution.
--=-ROvRVFBr24mAnx70Vv/c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWxYuVAAoJEOVv75VaS+3OrXsP/35JO/rOfdTB9W+zVLT0BMmO
AMTRIUuwjWYMTdjRdOEKnbkOjajBk8t6qKkc1C27v2kj+gsHhf+0KXuwYlZwxPlZ
0NZqPb1M+/Ie0O9tySvR+nOWOJXFSKGPtgpozeQAjdt3vjKQ2WeSJlIlMjMhxGDc
cpRPb/xpb51nF05ikDHJe73Q5jaTqajYo66RadI1vLW7UBZVLhGKNGwjGogQYuo9
CuWx0ljjxODjk4Zee8vKBPFF2v2utRT+nmvrAL2v4YwLLr3uKoveMYHB97JlqXkB
0WXrd3+Fn6se4ZaO6pF4OBpZNhkiKTwgY9CY/ffmbu/Hq0HBGW2G7LeBydXFPGwa
W1BIXCxJAgZLIvU1S69kLd8BKPdQ1GqgRXceJ5mtUO1HupDkt6J4dTJZ6CQXzYmT
9vnmdVq7rXGhrts+WkHqo08qMscDfg5J7bhzk2BM6tj2TlHWT9Odda7NSuZO2PEb
5tBtj9DZK/GdwHUxZPW8eJIkK+BAxc1bPqHpDcpvMkM0i4qfl+2wU79vU4dOlQ0P
NZBRgfUUEZzpZqHYOb/aZ38LelibypviRDkTa4z5fMYUhw3MQU4rvp/pKdUoT5Tl
rEgDN18sqKjNN8pztCaJ/ZISfYapsVs7ULmCUZ3tlm4y9uC1bAMZtoI4YQKr3665
KvjkGiP6YskJmzfJK4aK
=li9p
-----END PGP SIGNATURE-----

--=-ROvRVFBr24mAnx70Vv/c--
