From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 7 Feb 2012 20:57:29 +0100
Message-ID: <20120207195729.GA26533@pandem0nium>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <20120207110522.70663963@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cora.hrz.tu-chemnitz.de ([134.109.228.40]:37343 "EHLO
	cora.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab2BGT5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:57:30 -0500
Content-Disposition: inline
In-Reply-To: <20120207110522.70663963@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07, 2012 at 11:05:22AM -0800, Stephen Hemminger wrote:
> On Tue,  7 Feb 2012 19:39:08 +0100
> Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:
>=20
> I don't understand why this is better, we already have mark to do this.
> Your method saves adding a tc filter to map mark to classid, but that is =
hardly
> a huge burden.

Unfortunately, it is. We have previously built our trees by setting marks w=
ith iptables
and matching the masks with tc and the u32 matcher, but we got a rather big=
 performance
impact as soon as the number of users grow. The target platform are WiFi ac=
cess points.
By using the proposed patch, the performance stays nearly constant at a gro=
wing number
of users.

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk8xgigACgkQrzg/fFk7axZQMACdGJ8H81zE2J5qoL+Tlu4JU5TA
mpwAniVC5NP31mAWZ2K5ShofZr8SzpRV
=l+Wy
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
