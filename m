From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Thu, 20 Sep 2007 18:40:51 +0200
Message-ID: <1190306451.18521.90.camel@johannes.berg>
References: <20070919181005.GB5483@tuxdriver.com>
	 <46F19DD0.2050605@gentoo.org> <20070920134730.GC6748@tuxdriver.com>
	 <46F28374.9040106@gentoo.org>  <46F2A1D4.9030601@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zSri8TA2AM+FuxHR7iwl"
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46F2A1D4.9030601-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-zSri8TA2AM+FuxHR7iwl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-20 at 11:37 -0500, Larry Finger wrote:

> You're on. BTW, I will let you be the primary tester of "[PATCH] fix soft=
mac lockdep reports" that
> Johannes posted earlier today. I see you were CC'd. I plan on testing it =
with bcm43xx, but I won't
> get to it for a couple of days.

The only thing it can possibly fix is our race against some other
functions that use the global workqueue and lock the RTNL from within
the work function while we have it locked while flushing. Conversely, it
can't really break anything either.

johannes

--=-zSri8TA2AM+FuxHR7iwl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG8qKT/ETPhpq3jKURApx9AKC2G9Ce0qqwXOaqtG/b51uxCkIeSACguuQ0
WCYNk9qZ0iTX9FFwwnxs6N0=
=LU49
-----END PGP SIGNATURE-----

--=-zSri8TA2AM+FuxHR7iwl--
