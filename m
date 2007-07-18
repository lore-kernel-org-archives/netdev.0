From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: fix GCC warning on 64bit platforms
Date: Wed, 18 Jul 2007 18:00:24 +0200
Message-ID: <1184774424.4002.10.camel@johannes.berg>
References: <20070714.185935.18577806.davem@davemloft.net>
	 <20070714.204116.23012949.davem@davemloft.net>
	 <20070716184653.355253bf@griffin.suse.cz>
	 <20070716.145358.35015496.davem@davemloft.net>
	 <20070718171044.2de287cd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cMOtrpgLuykpVVEPw8VL"
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48348 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934634AbXGRQ5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 12:57:22 -0400
In-Reply-To: <20070718171044.2de287cd@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cMOtrpgLuykpVVEPw8VL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-18 at 17:10 +0200, Jiri Benc wrote:
> net/mac80211/ieee80211.c: In function ieee80211_register_hw:
> net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer ty=
pes lacks a cast
>=20
> Size of ieee80211_tx_status_rtap_hdr structure will never be greater than
> unsigned int.

Thanks Jiri, just noticed that it was actually my bug.

johannes

--=-cMOtrpgLuykpVVEPw8VL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnjkX/ETPhpq3jKURArfXAJ4mFw6lfkbdR4aZcJah2Cu/O33nQACgs8lI
n5Y0R4TpLeyZPv/+5BS/QTs=
=XvYK
-----END PGP SIGNATURE-----

--=-cMOtrpgLuykpVVEPw8VL--

