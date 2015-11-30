From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Mon, 30 Nov 2015 19:30:15 +0100
Message-ID: <565C95B7.7070001@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="GsxKItogWvGvq7jKO1rVlTC6fK8WXGF9W"
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448906497.3546.16.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GsxKItogWvGvq7jKO1rVlTC6fK8WXGF9W
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 30.11.2015 um 19:01 schrieb Paul Bolle:
> [DRAFT] gigaset: don't free() a struct platform_device
>=20
> One is not supposed to free() a struct platform_device. Instead one
> should, in the common case, only call platform_device_unregister(). Tha=
t
> will drop the platform device's reference count. (Actually it's the
> reference count of the embedded kobject that is important here. But for=

> users of platform devices that's basically irrelevant.)
>=20
> So move struct platform_device dev out of struct ser_cardstate, because=

> ser_cardstate is (malloc'ed and) free'd.

I wonder how that will behave if someone attaches two of the devices to
different serial ports. Not likely, but not forbidden either.

Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--GsxKItogWvGvq7jKO1rVlTC6fK8WXGF9W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXJXKAAoJEFPuqx0v+F+qy+EH+gMy8xuvxvDC24DqOsqOjy0/
wZ4bn3p2hexuG1XfIbODBc78i+aEmMENojby5z+wIDeWurjxV+r0BfFlCgusFHhk
NphJsKhJl8Qva8rHmgMG3sXXybZmlMro/z2K/ph7OgI5OlE+Ci94cP4GWe8fFWb3
CJJnk/DOrV5Eb1KbejpkOeqVb3WKri5akoqiuBAIK8XV1Kmb6xSDZb6pNRpcvPfk
3QNbl7V4vfbW8Piy3Dpr7w0Zw1GMYyjirNW4xryfNuXZn3HAxbWOWCfRcKDsJF0K
zX2h+vJgYKbPmYdXxoJGH15f8goM0tiFzuI605Ck2Jgvlki3TcrodB9eI8cdpMI=
=P/Cn
-----END PGP SIGNATURE-----

--GsxKItogWvGvq7jKO1rVlTC6fK8WXGF9W--
