From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC PATCH 6/9] ethtool: Add support for toggling any of the
 GSO offloads
Date: Sat, 19 Mar 2016 00:18:04 +0000
Message-ID: <1458346684.2953.16.camel@decadent.org.uk>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	 <20160318232516.14955.2907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-of5KfXDRF2+up2f1Y7NY"
To: Alexander Duyck <aduyck@mirantis.com>, ecree@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35400 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbcCSASO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 20:18:14 -0400
In-Reply-To: <20160318232516.14955.2907.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-of5KfXDRF2+up2f1Y7NY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-18 at 16:25 -0700, Alexander Duyck wrote:

> The strings were missing for several of the GSO offloads that are
> available.=C2=A0=C2=A0This patch provides the missing strings so that we =
can toggle
> or query any of them via the ethtool command.
>=20
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> =C2=A0net/core/ethtool.c |=C2=A0=C2=A0=C2=A0=C2=A03 +++
> =C2=A01 file changed, 3 insertions(+)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 2966cd0d7c93..b3c39d531469 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -82,9 +82,12 @@ static const char netdev_features_strings[NETDEV_FEATU=
RE_COUNT][ETH_GSTRING_LEN]
> =C2=A0	[NETIF_F_TSO6_BIT] =3D=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-tcp6-segmentation",
> =C2=A0	[NETIF_F_FSO_BIT] =3D=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"tx-fcoe-segmentation",
> =C2=A0	[NETIF_F_GSO_GRE_BIT] =3D		=C2=A0"tx-gre-segmentation",
> +	[NETIF_F_GSO_GRE_CSUM_BIT] =3D	=C2=A0"tx-gre-csum-segmentation",

All of the existing checksum offload names include the word "checksum"
in full, so I think the new names should do the same.

> =C2=A0	[NETIF_F_GSO_IPIP_BIT] =3D	=C2=A0"tx-ipip-segmentation",
> =C2=A0	[NETIF_F_GSO_SIT_BIT] =3D		=C2=A0"tx-sit-segmentation",
> =C2=A0	[NETIF_F_GSO_UDP_TUNNEL_BIT] =3D	=C2=A0"tx-udp_tnl-segmentation",
> +	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] =3D "tx-udp_tnl-csum-segmentation",
> +	[NETIF_F_GSO_TUNNEL_REMCSUM_BIT] =3D "tx-remcsum-segmentation",

I think this should be "tx-tunnel-remote-checksum-segmentation", though
that is getting quite unwieldy.

Ben.

> =C2=A0	[NETIF_F_FCOE_CRC_BIT] =3D=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0"tx-checksum-fcoe-crc",
> =C2=A0	[NETIF_F_SCTP_CRC_BIT] =3D=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0"tx-checksum-sctp",
>=20
--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.
--=-of5KfXDRF2+up2f1Y7NY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW7Jq8AAoJEOe/yOyVhhEJwmgP/2NpLVkqyPFAeFQqdFmU2zvq
H0bty4Z66dGj30bG7biIUtzla18ONjX5aRIdXuz52i626tUln0N94je/i3Aoj9h0
9PORmpa5xf1Xm8PCtOtTXyYA0Gxy0LRJs2ansLCOPh8hf52/LPqNf10Mv5O1E6Rf
dBv1XpI8v9l00PVcHG0VDqqojbXP1oQ3YEQD2kgFBNOO0ijMbO1zEVNwaZyEzgPy
yVNerqHGtVJHh3pdb7FGF2HVJmXHUUxAJZpBSqmnUXcuY3HbOm0aTH2geRgA2Bf8
lbEpW0gvZa8g9oG8Q/OX8zxNabgkoyrmomxPPgK8RUJGFqn7be127l4cnBtiJ0K0
3/NCNFw0NreEeqNbQvYrnt0k3GXyuiCM5HcJJIgd6gd2Ca4IuiewkbBp2KM487hR
84Dq7Z/7e+YUkN0Nh5By8U/AjrL5SMshZHUCfKXW6B1pxue1qmXeW55tE1its2yg
DZmBpVCCgm48/Y77g70OcT6m5MAGShtpy4BpxJBmzgBZDJcLaOYAKzzjVQH6tMbV
5oHUf2ii31hCTFXu+YICW9pUk8kuJDNTYXGInyT1g+dfClTKj4qpvxCkAsZlvFXG
akQle29kc/pZKbvfRVUQomH6qMb4eHqlZ2A9STOR8i18T89S4Wvir54sQ2OQ75B2
t1b5U2nNGkOyI6Dq0nX8
=FMU4
-----END PGP SIGNATURE-----

--=-of5KfXDRF2+up2f1Y7NY--
