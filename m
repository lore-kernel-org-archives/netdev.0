From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn: Return -EINTR in gigaset_start() if locking attempts
 fails.
Date: Sat, 17 Mar 2012 11:31:55 +0100
Message-ID: <4F64681B.8030406@imap.cc>
References: <1331903413-11426-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4DE7A07E51A22DB415AFD90E"
Cc: hjlipp@web.de, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1331903413-11426-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4DE7A07E51A22DB415AFD90E
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 16.03.2012 14:10, schrieb santosh nayak:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>=20
> If locking attempt was interrupted by a signal then we should
> return -EINTR so that caller can take appropriate action.

NACK.

The return value of gigaset_start(), as documented in its
header comment, is:
 *	1 - success, 0 - error
Its callers rely on this. If you want to change it, you must
also change the documentation and the callers accordingly.
In its current form the patch would just break the driver.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig4DE7A07E51A22DB415AFD90E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAk9kaBwACgkQQ3+did9BuFsK7ACfbFVdNyHEQHIdPQBwdFoaOBRL
zvwAn2VU1GEKbCVw67P6G5UQPKEWyXOM
=c+S5
-----END PGP SIGNATURE-----

--------------enig4DE7A07E51A22DB415AFD90E--
