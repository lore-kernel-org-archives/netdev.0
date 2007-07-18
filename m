From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] negative groups in netlink_setsockopt
Date: Wed, 18 Jul 2007 12:10:52 +0200
Message-ID: <1184753452.4658.9.camel@johannes.berg>
References: <1184675164.3773.83.camel@johannes.berg>
	 <20070718.020821.15264737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Wb4z7PCXp5285DgttKVm"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40553 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbXGRKO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:14:27 -0400
In-Reply-To: <20070718.020821.15264737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Wb4z7PCXp5285DgttKVm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-18 at 02:08 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 17 Jul 2007 14:26:04 +0200
>=20
> > Reading netlink_setsockopt it's not immediately clear why there isn't a
> > bug when you pass in negative numbers, the reason being that the >=3D
> > comparison is really unsigned although 'val' is signed because
> > nlk->ngroups is unsigned. Make 'val' unsigned too.
> >=20
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
>=20
> Applied, but I updated the "(int __user *)" cast in
> get_user() to match as well when applying this.

Oh, good catch, thanks.

johannes

--=-Wb4z7PCXp5285DgttKVm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnecs/ETPhpq3jKURAuY5AJ9iiVfPjyhS+fsS7dt1bVrCn1VrpwCfa++Y
n0EHUlnUC+SEFF25NB/ra0g=
=hHRX
-----END PGP SIGNATURE-----

--=-Wb4z7PCXp5285DgttKVm--

