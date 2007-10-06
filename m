From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] ieee80211_if_set_type: make check for master dev more explicit
Date: Fri, 5 Oct 2007 22:23:21 -0400
Message-ID: <200710052223.25257.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041726.11744.flamingice@sourmilk.net> <20071004230248.GN6037@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1266976.70n2veFJy4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071004230248.GN6037-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1266976.70n2veFJy4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 04 October 2007 19:02, John W. Linville wrote:
> Alright...better?
>
Yup, thanks.

> The problem is caused by ieee80211_if_set_type checking for a non-zero
> hard_start_xmit pointer value in order to avoid changing that value for
> master devices.  The fix is to make that check more explicitly linked to
> master devices rather than simply checking if the value has been
> previously set.
>
> CC: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Acked-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>

-Michael Wu

--nextPart1266976.70n2veFJy4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBvGdT3Oqt9AH4aERAgtyAJsG6HfheUW+fYvMGONp6BeTeblaSACdG4oj
KUa/ck5ghM4q3G8EO9+GG3w=
=/UQk
-----END PGP SIGNATURE-----

--nextPart1266976.70n2veFJy4--
