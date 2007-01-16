From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: Allocate array of pointers for nla_parse
Date: Tue, 16 Jan 2007 10:42:18 +0000
Message-ID: <1168944139.9175.3.camel@johannes.berg>
References: <200701161113.52523.marcus@better.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uasRC8JyVaBqoDDAhv9l"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50292 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbXAPKma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 05:42:30 -0500
To: Marcus Better <marcus@better.se>
In-Reply-To: <200701161113.52523.marcus@better.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uasRC8JyVaBqoDDAhv9l
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-16 at 11:13 +0100, Marcus Better wrote:
> The code allocates an array of struct nlattr, but it seems to me that it =
should allocate an array of pointers.
>=20
> Signed-off-by: Marcus Better <marcus@better.se>

Yup.
Acked-by: Johannes Berg <johannes@sipsolutions.net>

> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -843,7 +843,7 @@ static int nl80211_initiate_scan(struct sk_buff *skb,=
 struct genl_info *info)
> =20
>  		channels =3D kmalloc(count * sizeof(struct scan_channel),
>  				   GFP_KERNEL);
> -		tb =3D kmalloc((NL80211_ATTR_MAX+1) * sizeof(struct nlattr),
> +		tb =3D kmalloc((NL80211_ATTR_MAX+1) * sizeof(struct nlattr *),
>  			     GFP_KERNEL);
> =20
>  		count =3D 0;

--=-uasRC8JyVaBqoDDAhv9l
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFrKwJ/ETPhpq3jKURAhEaAKCmV5MT37xBbHbkG5BX8fuuru3+CQCfV9Se
g4hgKWH4024xDHrvE55ZPM0=
=qut9
-----END PGP SIGNATURE-----

--=-uasRC8JyVaBqoDDAhv9l--

