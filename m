From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool V3 1/2] ethtool: Add copybreak support
Date: Sat, 05 Sep 2015 10:48:59 +0100
Message-ID: <1441446539.13323.4.camel@decadent.org.uk>
References: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
	 <1434024928-33177-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-E02jBfnuNpRc2pRw//v1"
Cc: netdev@vger.kernel.org, _govind@gmx.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45422 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752417AbbIEKlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 06:41:53 -0400
In-Reply-To: <1434024928-33177-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-E02jBfnuNpRc2pRw//v1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-11 at 15:15 +0300, Hadar Hen Zion wrote:
> From: Govindarajulu Varadarajan <_govind@gmx.com>
>=20
> Add support for setting/getting driver's tx/rx_copybreak value.
>=20
> Copybreak is handled through a new ethtool tunable interface.
>=20
> The kernel support was added in 3.18, commit f0db9b07341 "ethtool:
> Add generic options for tunables"
[...]

So why have you sent a patch that only handles copy-break?  The kernel=20
tells us the type of each tunable and ethtool should use that to decide
how to print and parse values.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.


--=-E02jBfnuNpRc2pRw//v1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVeq6i+e/yOyVhhEJAQq2Xw/+Jv7ePHrW1LWqscezO+weVrWuswVEJUe7
mmDw2vXL1NtD8zOiR86AUnjA6caQUWNUW/qvweSjflweDs+NKDl96Pv5VyoVAeJX
S7zzYElC8ie5jW7bv6vxzRmdZsMmem16ciNU6VXhaMlFPupG8q2tIHv33WWYg005
6U1n+rxS8t2DTGF593VDuMnqEM9uOPZ4VUVYxUK+Np+Sff8dgHzCYWvUQeq6iLEQ
A2QKB+JjMgykoY37rVkxom1GFk+7Hwmn4QX09n8lQuI0+HteROKP7sJoWoBeLSOy
NsMM+rPK+0jRaYSkc/7kpuHOz5kHD1rxtgRaJT0g9d49JdP9U3ul9GuUCxA4yguD
T3id7/dZwZU2xqsQQijAsKuNjiG0uFebygxQPP4IJQ85EBX/f69w3X3M2SEfrNn8
r7nHtDjldHjiVxcUfE7VvLvZEu/ZzD1YzsVaHVhLYIsvjAlmynQhckTWvdJkLBdc
XMR13jSoiOufXF6IeUI2VPyC6ZGuNf3vnRjg7V9x7D9lmHUeXrcHjVyHFwtpezlL
XP4Y6kmFwdxJdr6Fh7tKubD9iEX+RsUQJOEiGtRpDhwBmtR2lYBqIdtm6VknUnDY
2qTMKZm27p2eLzodfqDAbFtE1s9Oo9H0cYTgQcyBjI7ZOJBZbHD6dFQ9lU/XxmtR
s8FbDTu17pM=
=cyA5
-----END PGP SIGNATURE-----

--=-E02jBfnuNpRc2pRw//v1--
