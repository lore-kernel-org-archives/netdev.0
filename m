From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Correct conditional compile of wext-common.c.
Date: Tue, 23 Jan 2007 18:41:42 +0100
Message-ID: <1169574102.3649.16.camel@johannes.berg>
References: <200701211819.07947.marcus@better.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ezcS7PiwkiN9tgchHfDq"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36914 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965256AbXAWRm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 12:42:26 -0500
To: Marcus Better <marcus@better.se>
In-Reply-To: <200701211819.07947.marcus@better.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ezcS7PiwkiN9tgchHfDq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-01-21 at 18:19 +0100, Marcus Better wrote:
> wext-common.o is required if CONFIG_WIRELESS_EXT is set. Looks like `CONF=
IG_NET_WIRELESS' is a typo.
>=20
> Signed-off-by: Marcus Better <marcus@better.se>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> --- a/net/wireless/Makefile
> +++ b/net/wireless/Makefile
> @@ -12,5 +12,5 @@ obj-ny :=3D
> =20
>  # this needs to be compiled in...
>  obj-$(CONFIG_CFG80211_WEXT_COMPAT) +=3D wext-compat.o
> -obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_NET_WIRELESS) +=3D wext-commo=
n.o
> +obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_WIRELESS_EXT) +=3D wext-commo=
n.o
>  obj-y +=3D $(obj-yy) $(obj-yn) $(obj-ny)

--=-ezcS7PiwkiN9tgchHfDq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtkjW/ETPhpq3jKURAlWxAKCjtK8B/7A/Yr9YCTPkPZPr83iEogCcD2XZ
XSheaZTLCpb+raoivpqhC3Y=
=sMuM
-----END PGP SIGNATURE-----

--=-ezcS7PiwkiN9tgchHfDq--

