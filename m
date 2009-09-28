From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Mon, 28 Sep 2009 09:54:28 +0200
Message-ID: <1254124468.6583.13.camel@johannes.local>
References: <1254076075.6583.6.camel@johannes.local>
	 <Pine.LNX.4.64.0909272139280.4061@sister.anvils>
	 <Pine.LNX.4.64.0909272237190.4098@sister.anvils>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wTAMF1UfCbYJ2NlChyP1"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51745 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbZI1Hy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 03:54:27 -0400
In-Reply-To: <Pine.LNX.4.64.0909272237190.4098@sister.anvils>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wTAMF1UfCbYJ2NlChyP1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-09-27 at 22:50 +0100, Hugh Dickins wrote:
> On Sun, 27 Sep 2009, Hugh Dickins wrote:
> >=20
> > I've experimented by moving your NETDEV_PRE_INIT hunk later in the
> > sequence, just before the netdev_initialize_kobject(dev) (so I also
> > changed the "goto out" to "goto err_uninit"): both* machines then boot
> > correctly, and this mail leaves me wirelessly.
> >=20
> > I'll now experiment to see how early I can move that hunk.
>=20
> Both machines boot (and do wireless) correctly with your NETDEV_PRE_INIT
> hunk placed just after the ndo_init block, instead of just before where
> you placed it.  That's i386 kernels on both.
>=20
> But curiouser and curiouser... the laptop can do 64-bit, so I built
> my 64-bit kernel, and went through the motions to reproduce the
> early boot crash with the patch as you had it: but the x86_64 kernel
> boots (and does wireless) correctly with the NETDEV_PRE_INIT hunk
> just where you placed it, before the ndo_init block.
>=20
> Perhaps there's a difference in the 32- and 64-bit startup sequence
> with respect to notifiers; or perhaps your change tickles another bug.
> I don't know, I'm turning off now.

Interesting, thanks for taking the time to test. I'll post an updated
patchset that calls it POST_INIT and moves it to there.

johannes

--=-wTAMF1UfCbYJ2NlChyP1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIbBAABAgAGBQJKwGusAAoJEODzc/N7+Qmazl8P9ia9NKscvmR89VcCvK3hfZzx
kWzp9WCJvS4YqwuWCMW01peiRF4zGxz04HAM38/m1y6cjbwRX+NWRy/qd/vvavVl
DN12SIdxJ4eivQVLbHN0sVI9fLCptCp6Zz222NBHNBuKP1n1jK3PkWY0ovlIZ/VM
MHqjA6eExr4dn7/0WqlPaSOs7W79PNqhRVqX5mJAAdslX5XNCFbZLbhmU4G02AnA
/IYKjIZxkDds8BXvqbS8Zb5EepwsciT2C4KuGRf5q9jMFGKx7Xi3lPGQYQTn7fPz
yVz84v9B+VFpPK7s7hbBL5rO3Zz/EIjH4pmGvjiaHXG5rzf6jFClweJZjfo1xf69
l/SHV77jwsTjpr5ZfGeiFW36WA1m4jAMSq7YizUluWYkA7hygrFl0sYa6cbw6Dqs
CXYGamfZp7Vx0ZqhVqve9tlBDWYLvu/ZpQ6QDRZaSuHsS3RC3vpVMJVDv8GhQQin
AFpILBhRsA9A4WhtJY6ngeFqhE+TDPSwApcHDid6XP05oz60JjhcBRzCWgfMG7cZ
cuAR7EHRGHQ/VjKEr0RCB0HsX+LhHmGBsyrDP2MOC+JJWrBX4LA53+j7LuA9aPez
YBhvXBMMILulDvYPPGBvp6KPEyPG0zWJEE5Ir8F2AvEKJehMscxsNSss720NqaMl
mMA+yp+XVF2GIyzZ9UM=
=yxvI
-----END PGP SIGNATURE-----

--=-wTAMF1UfCbYJ2NlChyP1--

