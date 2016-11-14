From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 3/3] net: ethernet: sun4i-emac: Read rxhdr in CPU
 byte-order
Date: Mon, 14 Nov 2016 19:59:34 +0100
Message-ID: <20161114185934.2wfwyrv6buvnrja7@lukather>
References: <20161114175807.4747-1-michael.weiser@gmx.de>
 <20161114175807.4747-4-michael.weiser@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wr5fexqw4bqqevgu"
Cc: netdev@vger.kernel.org
To: Michael Weiser <michael.weiser@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:52748 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932605AbcKNS7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:59:45 -0500
Content-Disposition: inline
In-Reply-To: <20161114175807.4747-4-michael.weiser@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wr5fexqw4bqqevgu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 14, 2016 at 06:58:07PM +0100, Michael Weiser wrote:
> The EMAC EMAC_RX_IO_DATA_REG data register is dual-purpose: On one hand
> it is used to move actual packet data off the wire. This will be in
> wire-format and accepted as such by higher layers such as IP. Therefore
> it is correctly read as-is (i.e. raw) using readsl.
>=20
> On the other hand it provides metadata about incoming transfers to the
> driver such as length and checksum validation status. This data is
> little-endian, always and it is interpreted by the driver. Therefore it
> needs to be swapped to CPU endianness to make sense to the driver. This
> is already done for the "receive header" but not rxhdr.
>=20
> Read rxhdr using readl in order for sun4i-emac to work correctly when
> running a big-endian kernel.
>=20
> Signed-off-by: Michael Weiser <michael.weiser@gmx.de>
> Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
> Cc: netdev@vger.kernel.org

Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--wr5fexqw4bqqevgu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKgmVAAoJEBx+YmzsjxAgCxEP/2GwkHmtVeTbL97yE2OjyIPZ
3aSiIIadTQ67kWTxpr2HOvBap533xPK5cWNgbTBKCzk7NrAo1Zo1FQAxtUMahuGy
MlstIvy2xamt19JstWh40MK/RpZX2tOjWP4aCrl5RsIvV7crcKZySxH6XK9apHsk
FGJI89N9cH6a2f2LCBVhkuYhJprUdxuZ4n8EuiqmaOCoMbkkwxI5vO3apVGmP8ZT
9LDIZvpa4XjLg0N/obpG1eyWSFVOvFxjX8NjKp5Ucsfi8ALGrzTljXLFWZjaY4V0
UHUJFmYaowcSq6jKw4lcXi+OU2Q/BBdIETrQsWZPIk2xmbXjkfl3ih6GOxKUCXQD
2Kk6wdrC3fwLuL9q8NEFD9VViJjgkuTcwbn6shNaGYy32O8TlYyQcmcPII61uXmi
E03Y4x24ytwypIQ77QmrIe+HeH11Tdlexb2EhjCk11KuGnnsrkLaESwkJGsL7+55
q3ThGL/7DxXAhc1G4Yr2kw6dRgvtdQ6geap1QG3sXU8oPSzjoWLFCeuAlQ6FvPIe
1afXc7rIBKpJK//VNDkcB0X26hqrXOZDhBpqSAZ6REwiiXWE7fXju1VrKOD31YwW
RS6yDOhOydnRpM4NkuC6sDb02C6P+h2yOS1dsBDmZLOwaFDyQXVI4lNa8JmJPoDx
q/yKBdlgVNkbVNYMN0Hx
=4hm2
-----END PGP SIGNATURE-----

--wr5fexqw4bqqevgu--
