From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 05/13] ethtool,net/mlx4_en: Add 100M, 20G, 56G
 speeds ethtool reporting support
Date: Wed, 05 Nov 2014 22:38:37 +0000
Message-ID: <1415227117.3398.31.camel@decadent.org.uk>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
	 <1414402667-8841-6-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0+jfY9NWXk3mKqnCSpV3"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55569 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbaKEWit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:38:49 -0500
In-Reply-To: <1414402667-8841-6-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0+jfY9NWXk3mKqnCSpV3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-10-27 at 11:37 +0200, Amir Vadai wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
>=20
> Added 100M, 20G and 56G ethtool speed reporting support.
> Update mlx4_en_test_speed self test with the new speeds.
>=20
> Defined new link speeds in include/uapi/linux/ethtool.h:
> +#define SPEED_20000	20000
> +#define SPEED_40000	40000
> +#define SPEED_56000	56000
>=20
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
[...]
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1213,6 +1213,10 @@ enum ethtool_sfeatures_retval_bits {
>  #define SUPPORTED_40000baseCR4_Full	(1 << 24)
>  #define SUPPORTED_40000baseSR4_Full	(1 << 25)
>  #define SUPPORTED_40000baseLR4_Full	(1 << 26)
> +#define SUPPORTED_56000baseKR4_Full	(1 << 27)
> +#define SUPPORTED_56000baseCR4_Full	(1 << 28)
> +#define SUPPORTED_56000baseSR4_Full	(1 << 29)
> +#define SUPPORTED_56000baseLR4_Full	(1 << 30)
> =20
>  #define ADVERTISED_10baseT_Half		(1 << 0)
>  #define ADVERTISED_10baseT_Full		(1 << 1)
> @@ -1241,6 +1245,10 @@ enum ethtool_sfeatures_retval_bits {
>  #define ADVERTISED_40000baseCR4_Full	(1 << 24)
>  #define ADVERTISED_40000baseSR4_Full	(1 << 25)
>  #define ADVERTISED_40000baseLR4_Full	(1 << 26)
> +#define ADVERTISED_56000baseKR4_Full	(1 << 27)
> +#define ADVERTISED_56000baseCR4_Full	(1 << 28)
> +#define ADVERTISED_56000baseSR4_Full	(1 << 29)
> +#define ADVERTISED_56000baseLR4_Full	(1 << 30)

Can these modes be auto-negotiated?  If not then they don't need
advertised/supported bits.
=20
>  /* The following are all involved in forcing a particular link
>   * mode for the device for setting things.  When getting the
> @@ -1248,12 +1256,16 @@ enum ethtool_sfeatures_retval_bits {
>   * it was forced up into this mode or autonegotiated.
>   */
> =20
> -/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
> +/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
>  #define SPEED_10		10
>  #define SPEED_100		100
>  #define SPEED_1000		1000
>  #define SPEED_2500		2500
>  #define SPEED_10000		10000
> +#define SPEED_20000		20000
> +#define SPEED_40000		40000
> +#define SPEED_56000		56000

We shouldn't add new SPEED macros.  The speed is just a number of Mbit/s
and we don't need to enumerate the possible values.

Ben.

>  #define SPEED_UNKNOWN		-1
> =20
>  /* Duplex, half or full. */

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.

--=-0+jfY9NWXk3mKqnCSpV3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFqm8ue/yOyVhhEJAQo4MA//YUcQQaQ56GV5CSlihYVetHZUNRiT0dJT
rzn+ynx0cM3RjqRNhBIHaoi4C4/YM6K8VJZslHrPD8qizAfT2LMcaq/WOsc++OV+
WZIHf47pZRR4504MHkN5LoY0ruDaglrtwLlUvOR/uIGxzMWtA5W7p/T2khciyU42
GE1kDQhefV/v45gzvPUuORx0QhdO2kWe+KSMAZJiculJOcnA4ZvFgpYyTnxjYjl9
4WFdBZcYZfcohmMnfUqgto+zhpNsb56B4ldNUtUCDHncM4vWxrclD3B1iddOWxrC
TdkyVwS1buT8y0ddkQrlUalQD+3Rbu4RI1s7mSL+t4kZQs+V22T3YtK8C900SPGO
x6N63IfT1lnjYTpLXuaZbPrbhKjHBiJzqh3PSlonHANmi9tsEtOUIx99Ql6/CbRi
X6oY9pqEByROrbmXrPrGzC1gHt3PqxUNvr2DWM4PQtyK2AKiUEiqj5WKEY9g4QiW
C7CnhYxiiPeeJhLXcwmpVsTiFmgcUPkXre93jBfHXh/klKOTqCXnKlEhLzjYJLEw
D7MuCikK1OD9cRIBdzwN3shFF7P54AljtSaphZZfN17wiJoUV8tvnHWN9r7MfOlN
yBsPiVRnzFphjPr3IiQbQ+25N27i5PJ312uLqZNNf+kXRyvg2kUGES6XqpmAz6aZ
FuDlSB2Opfk=
=GimS
-----END PGP SIGNATURE-----

--=-0+jfY9NWXk3mKqnCSpV3--
