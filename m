From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [2.6.31-rc1] iwlagn (4965): no wireless due to RFKILL problem
Date: Fri, 26 Jun 2009 22:28:52 +0200
Message-ID: <1246048132.21314.75.camel@johannes.local>
References: <200906261336.29318.elendil@planet.nl>
	 <8db1092f0906260459n308311faweb6d9733cdd1eb13@mail.gmail.com>
	 <200906261410.58808.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-DlnSatDCB9FybzTwLexr"
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Alan Jenkins <alan-jenkins@tuffmail.co.uk>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:56088 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbZF0IQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2009 04:16:56 -0400
In-Reply-To: <200906261410.58808.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DlnSatDCB9FybzTwLexr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-06-26 at 14:10 +0200, Frans Pop wrote:

> Well, with 2.6.30 hp-wmi worked together with rfkill without problems.
> Looking at the commit logs, it looks like the rfkill rewrite by Johannes=20
> and Alan is the cause here. CCs added.

Hmm, looks like there might be another polarity error, try this:
-       int query =3D BIT(b + 8) | ((!!blocked) << b);
+       int query =3D BIT(b + 8) | ((!blocked) << b);


johannes

--=-DlnSatDCB9FybzTwLexr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKRS+BAAoJEODzc/N7+QmaodoP/3yeMqx2sSs7dJVumrgbNlWY
GqiAlB1/FXAXnyrfAecQf3Bl8UDQciGws7RcUc4ZKmaX8B702nXy1CLre93Z1uGc
Kc0DDkEh1zkybbg9q/JsG5MW4GDXVbO5Vh6Ux703ImxJAonU0LgHhGMDwhzebEir
6x6eyHzVtBG3D1Ywk1p8j6+sF5OYw1em0cp3WaQSlkQKLMLsxYdDqS6wDKbpfZWK
bIv8t2W/Uc1hOM1C8p6BU9zMezeRDsc/ky6VtnnabeWetODmVA1OEAgrf0J53SxE
mKyRpnzPnbEGb+CkE+jrkfI26bvLsX1sWz/WI42qVonzIcVp0ZzqBgGotZmDbGCo
7dtNxOC5XWalydukcnauF4MrILN2jiy0wgPYGjXm9P8Ud5vWF7loayLnWGkjGbKo
KU+WtN9Ev9CZ0JzfKCGnGAnNbCCzM/BItAlHC1DLIZwXP3WRUS7THOFJN8pUSia0
za40iBLT6zPooPXisDoOjWKNRUP+uTdVdrDKbLJFNGs4kBhDvwDgY2aWZ+nSmM6b
hxfIBpUCPKByoqaAsgX/LGUmotixIIoy18glIPHf5hRcHb2mzpFzvVZ26mpy7OBW
VhasUk98RWA3knPLtfb3anLUOBBoESsPInCBHVeB4UXAXlDpySvSuFUnbTVMAMdq
gNRp0WxbiwZv8G9h8rxf
=56xK
-----END PGP SIGNATURE-----

--=-DlnSatDCB9FybzTwLexr--

