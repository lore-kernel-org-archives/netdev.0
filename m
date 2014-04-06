From: Ben Hutchings <ben@decadent.org.uk>
Subject: nl802154 UAPI definitions
Date: Sun, 06 Apr 2014 23:22:15 +0100
Message-ID: <1396822935.13361.9.camel@deadeye.wl.decadent.org.uk>
References: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	 <1396271873-10300-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ze560DAGDKu2+wAVPBiO"
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59284 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753726AbaDFWW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 18:22:27 -0400
In-Reply-To: <1396271873-10300-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ze560DAGDKu2+wAVPBiO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-31 at 15:17 +0200, Phoebe Buckheister wrote:
[...]
> --- a/include/linux/nl802154.h
> +++ b/include/linux/nl802154.h
> @@ -132,7 +132,7 @@ enum {
>  	IEEE802154_ADD_IFACE,
>  	IEEE802154_DEL_IFACE,
> =20
> -	IEEE802154_SET_PHYPARAMS,
> +	IEEE802154_SET_MACPARAMS,
> =20
>  	__IEEE802154_CMD_MAX,
>  };
[...]

By the way, this header file belongs in include/uapi/linux (except for
the ieee802154_policy declaration).

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-Ze560DAGDKu2+wAVPBiO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0HTl+e/yOyVhhEJAQptNA//Wtlyqvwk5G2yELClPC7/LJA4WrwEaCk0
JbnqB5p0DrFlthRq9oMW40GEEk3oSM5XY0XYtLBP0JwiR3y7S/tqkWAS5TUvBBMA
YGspxvTUR/UBbdRARAgERegKpEopliBTFE5Owt7DY0hbdfNJl+Wdfw+ecseVpbyz
vDwJY9BsAeiTOXAnJQP9mS+uDp06opgaVA/HlWwhs15vUiuSxBl9krdJCOpoQ/2i
2+o03qimvtQEP2fQXnD29y545GpazRzIoSQ7BzdYu550g3NKLg93im7QKTYiHtiI
g1U2iXeirVC5g7pY9Sjmwuw5ZbiXqQf6WgNu5GD7xeH52RweSYV33B68rQU5xeZS
fRHmgWzF1rP8yZlrcg8GtmeMUCqvO8xunafHU7WdtL3LODfQFlNO9NJd37RvjCxC
1mrIaFahPi4Hg/aNVDhMFV0gzeekMSeP4qKx6KSzd6B9+TzwDOQWG74SUcz7/HpC
mkBQTokvw7HTqh/D7MBozL+KZsYAZuyuLix0q7e3SwZ9AJ9KUcSHj8Ga0uRAc+Te
/jR+i4soYSdKUXSUj/neOALfXQ56DwZG9QG4xebWsn2rujFdbf1Iloq2IUIlgpqQ
OqlF3i1W1agOd3/Op1IsHfaD3e03k5Xch4R4dUwSaydQwRDYbbItQS4DiJTDJTDN
2NCDTiBnpKk=
=7+sA
-----END PGP SIGNATURE-----

--=-Ze560DAGDKu2+wAVPBiO--
