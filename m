From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net-2.6.24 plans
Date: Thu, 20 Sep 2007 16:50:52 +0200
Message-ID: <1190299852.18521.71.camel@johannes.berg>
References: <20070918032328.GB3875@tuxdriver.com>
	 <20070919012752.GA3717@tuxdriver.com> <20070919210700.GF5483@tuxdriver.com>
	 <20070919.151928.122833514.davem@davemloft.net>
	 <20070920141723.GE6748@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/vZK/zCnyd82YIZK0iWc"
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40142 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbXITOtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 10:49:55 -0400
In-Reply-To: <20070920141723.GE6748@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/vZK/zCnyd82YIZK0iWc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-20 at 10:17 -0400, John W. Linville wrote:

> > 2) ATMEL USB driver
>=20
> These are both really new.  I think I'll transfer them to my
> wireless-2.6 tree, but still hold them back at least until 2.6.25.

Also, atmel isn't even ported to mac80211 yet, is it?

> > 3) NL80211
>=20
> I need to check w/ Johannes to see if the user-facing portions of
> this have stabilized.

I have a patch to basically remove everything from nl80211 that we're
not using today, and make the interface well-defined so each type of
setting has methods to "new, del, get, set", for example create, remove,
get info or change a virtual interface. If you wish, I can post this
patch for inclusion into wireless-dev and then copy the resulting
nl80211 to net-2.6.24, including the mac80211 hooks to make use of it.
Shouldn't take more than a few hours.

johannes

--=-/vZK/zCnyd82YIZK0iWc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG8ojM/ETPhpq3jKURAjpbAKCNhpDO5Z140Gg0mSUWvR+wbwiCugCgtyGM
Idvnz5SeMWLcrTPU+4bAJBs=
=MM/k
-----END PGP SIGNATURE-----

--=-/vZK/zCnyd82YIZK0iWc--

