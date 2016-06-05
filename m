From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC net-next 1/1] ethtool: Add support for set eeprom metadata.
Date: Sun, 05 Jun 2016 13:49:17 +0100
Message-ID: <1465130957.2847.195.camel@decadent.org.uk>
References: <1464269615-4937-1-git-send-email-sudarsana.kalluru@qlogic.com>
	 <CO2PR11MB00887A3F4C8ABB71421B1651975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fp4YtQECG+1LdwhAPgec"
Cc: netdev <netdev@vger.kernel.org>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38438 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750908AbcFEMt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 08:49:26 -0400
In-Reply-To: <CO2PR11MB00887A3F4C8ABB71421B1651975B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fp4YtQECG+1LdwhAPgec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-06-05 at 10:16 +0000, Yuval Mintz wrote:
> >=20
> > Currently ethtool implementation does not have a way to pass the metada=
ta for
> > eeprom related operations. Some adapters have a complicated non-volatil=
e
> > memory implementation that requires additional information =E2=80=93 th=
ere are drivers
> > [bnx2x and bnxt] that use the =E2=80=98magic=E2=80=99 field in the {G,S=
}EEPROM=C2=A0=C2=A0for that purpose,
> > although that=E2=80=99s not its intended usage.
> >=20
> > This patch adds a provision to pass the eeprom metadata for
> > %ETHTOOL_SEEPROM/%ETHTOOL_GEEPROM implementations. User provided
> > metadata will be cached by the driver and assigns a magic value which t=
he
> > application need to use for the subsequent {G,S}EEPROM command.
>=20
> Hi Dave,
>=20
> This got no comments at all.
> What do you want us to with it next? Should we re-send it as a patch?

Here's a comment: I really dislike this.

- It doesn't specify any semantics for the 'metadata'. =C2=A0The comment
hints that they are driver-specific identifiers for different NVRAM
partitions.

- It doesn't provide a way for userland to enumerate the valid metadata
values.

- It's not clear whether the driver is supposed to maintain just one
metadata:magic mapping, or more than that.

Is the ethtool API really the right interface for access to flash? =C2=A0Th=
e
sfc driver exposes a large number of flash partitions using MTD
instead. =C2=A0These can be enumerated (through /proc/mtd or sysfs) and the=
y
can be read and written through block devices.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0- Albert
Einstein

--=-fp4YtQECG+1LdwhAPgec
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXVB/OAAoJEOe/yOyVhhEJZeMP/jued7gr7yLH+X+8WkCpbM4g
z6PlkoMUmG5Wdyi6yazqBnqHmuvJFxyG8/h/ltPeu8loVjiHNPfdiJz4ndXcAKyx
G9gYcq3L/iXVqT+DXOj7xJmivYNtVs9u9JTPR5rkvYdVYWMUKByq7FFSaYGkQaN9
fPeKBXCVqgw/qG7soD4Jaay48HL54FLRZGRFuTx9b6lTi299P5gkdCeu6xPZOpKT
lsu2y/Yoy+08reyDerPUyyN4fiOgVYFrhmK+kMVR9qxqHO0CxmZWAujjcdTOs9Py
05G9qpPywyIrLQgnhUiU9ABjN7brlwIpQS+CnXlmJwhFKEMStmxSZUkeqBbfSoBj
hMkF8TzRwI0rcZBOWJrmENwXpYZo8z5yyqp+d1cyE6PNc12i+ows5N5YcF+FZI2B
yFFLwe3SPyNTWXpGcg90hXpnSburFcZmTyUJ0UZEO9MggJ76ZoIsX3EX0+lGBVXJ
B2d8xGKKNJuAfh8HYBzswn5fzuLGuWJ2vKG6YM4zuGacnC1jBNoR6T2Adliecyod
JZFE2pNdwobCm+/g6TBQspZcx0fLO/tBy8yKCWp1vqoisThaFlPELSBOyCaCnInC
fY1DOgRv2Yai6tWZQGphB9EfpQqwmWbNDqgUR3d0ZtTS6WpWk6y03QTOS6AGzsDy
htkpF1UdsaxXsi2OobHx
=Qtyj
-----END PGP SIGNATURE-----

--=-fp4YtQECG+1LdwhAPgec--
