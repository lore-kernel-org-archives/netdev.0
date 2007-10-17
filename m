From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 16 Oct 2007 23:29:51 -0400
Message-ID: <200710162329.55966.flamingice@sourmilk.net>
References: <20071017023145.GA2848@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3776809.t8rrTqrduP";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071017023145.GA2848-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart3776809.t8rrTqrduP
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 16 October 2007 22:31:46 John W. Linville wrote:
> Bill Moss (1):
>       mac80211: honor IW_SCAN_THIS_ESSID in siwscan ioctl
>
Where did this patch come from? The original patch looked nothing like this=
,=20
and this patch changes the behavior of siwscan incorrectly. If the interfac=
e=20
is not STA, IBSS, or AP, scanning should not be permitted. This patch allow=
s=20
scanning on any interface if a SSID is specified. NACK.

=2DMichael Wu

--nextPart3776809.t8rrTqrduP
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBHFYGzT3Oqt9AH4aERAv4AAJ9DW+5YFUFvdWRWqYAQYquGZUutLACglEEs
mYLw0WP/fm2vNAWdTbmyuJo=
=g5W2
-----END PGP SIGNATURE-----

--nextPart3776809.t8rrTqrduP--
