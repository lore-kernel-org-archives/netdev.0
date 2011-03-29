From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Tue, 29 Mar 2011 02:16:19 +0100
Message-ID: <1301361379.26693.742.camel@localhost>
References: <1300603423.1869.18.camel@dan>
	 <1300639685.26693.286.camel@localhost>
	 <20110327.175936.189721420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-Cjde4ouHHEaZ3hlnYAtb"
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	security@kernel.org, David Miller <davem@davemloft.net>
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36492 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752456Ab1C2BQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 21:16:30 -0400
In-Reply-To: <20110327.175936.189721420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Cjde4ouHHEaZ3hlnYAtb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-03-27 at 17:59 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 20 Mar 2011 16:48:05 +0000
>=20
> > Subject: [PATCH] rose: Add length checks to CALL_REQUEST parsing
> >=20
> > Define some constant offsets for CALL_REQUEST based on the description
> > at <http://www.techfest.com/networking/wan/x25plp.htm> and the
> > definition of ROSE as using 10-digit (5-byte) addresses.  Use them
> > consistently.  Validate all implicit and explicit facilities lengths.
> > Validate the address length byte rather than either trusting or
> > assuming its value.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Applied.

Ralf, I would really appreciate it if you could test this soon...

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-Cjde4ouHHEaZ3hlnYAtb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATZEy4ee/yOyVhhEJAQrT/hAAtkCxKVA+M5F60hj2cVDFWbSlxArO9/cF
ivvJGidSxW3dRgE1F3fO1HHG1TToH+cqstj6GwhnIHnRxFLz/ez7RQibSEmVaJXo
i+J9H7arge3e2dyeQ+A6BdSZU6yn8CsDeqFCcNBpN/S2b287BGiUa7seza16yShR
ndk5BiBlPaFGnRvhvlOKvmS3pZyKjhcFRTOIGN95h5xiQDaigFr4XFCMMFJX6YDJ
RtgVtNTaW8n8KQj7pz6AvB4o0gXtagnecS+M8sIi8j6OQ1agrT1z7BymhvU5AMsb
UK0f7lDhMtK5d3uL+2toiSV0e3p21yrOxvC7s/E18LyHesWTrCB6o3IEz9HSpovf
61P1WL8Fxu07fU99kpjyUsLb4B2JF7owlLGqdgcq2W2CxaGMWFlSwdt9JZb86BA5
7FKIMmR74D87DAJhwqxoby5ot3hI9lYbfPrTEWx4SAysB9bCTvNhn5A9L4K3BYyN
4yBrSE3cJqN1KXZG2myGDZD0Gu0BxcGf4mmkG7ZexMy5XvkQh+Rh8DkT+TS8h8vt
zCJhSRHoPl02aMA+iJ0asnToMdu+5kcX2/HdNA/qHaiYHNmKmE/ijbfiUPBt07Bm
3wPxxSkehYzS5cobLtBY5k6vYA8xI0TYnNMVMQi9YBkeq0AkXiferixQHy4yjhts
BR6BOh+knF4=
=z3IO
-----END PGP SIGNATURE-----

--=-Cjde4ouHHEaZ3hlnYAtb--
