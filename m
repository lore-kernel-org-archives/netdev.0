From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 4 Oct 2007 11:14:58 -0400
Message-ID: <200710041115.02945.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041034.48533.flamingice@sourmilk.net> <200710041706.06182.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3294882.C8Ou6vCo8u";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200710041706.06182.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart3294882.C8Ou6vCo8u
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 04 October 2007 11:06, Michael Buesch wrote:
> The reason why BUG_ON exists is to catch bugs that happen, although
> they Should Never Happen (tm) ;)
This is just paranoia. There's plenty of other BUG_ONs which we use to catc=
h=20
bugs caused by drivers doing silly things. We can verify that this conditio=
n=20
will never occur within the mac80211 layer, so there's no need to have it.=
=20
The only thing this can catch is someone deciding to manually invoke=20
dev->uninit, which only the unregister code should be doing.

=2DMichael Wu

--nextPart3294882.C8Ou6vCo8u
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBQN2T3Oqt9AH4aERAhkUAKDNagw/FPR6F73K7KnOGIY00SJInACg0Z6H
JapIyxbMHpwP8yy6XWyH614=
=c/eP
-----END PGP SIGNATURE-----

--nextPart3294882.C8Ou6vCo8u--
