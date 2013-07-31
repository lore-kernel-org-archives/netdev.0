From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 18:28:27 +0300
Message-ID: <20130731152827.GB25618@radagast>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-omap@vger.kernel.org>, <balbi@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43457 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab3GaP2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 11:28:40 -0400
Content-Disposition: inline
In-Reply-To: <20130731144957.GC4904@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 31, 2013 at 04:49:59PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 05:42:26PM +0530, Mugunthan V N wrote:
> > The new IP version has a minor changes and the offsets are same as the =
previous
> > version, so instead of adding CPSW version number in the driver, make t=
he driver
> > to fall through to the latest versions so that the new version of CPSW =
which has
> > the same register offsets will work directly without patching the drive=
r.
>=20
> This doesn't make any sense to me. Why not just add the new version
> number?
>=20
> None of the hunks in your patch are on performance sensitive paths, so
> I really can't see any point in removing the error checking.

well, if a new revision of the IP comes, the driver at least has some
chance to work without having to be modified. If it turns out that there
are really different features, then we patch a new version, otherwise we
should just assume highest known version and try it out.

--=20
balbi

--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+S0bAAoJEIaOsuA1yqREqiQQAJppTWd65kD8C3hDmvsirpf7
4a0Z2ZMVgSgblk2bVdL+clpRYa+SqsmKhpCbBCHgUJBPUoiq+zfUUb5m7LL4oFsN
3k7/9+XQ766YOQBk0VxkNDlGLHr8ZqOPAagH0mTjAaF7abcuV3EYk6r0XYJqKSKp
126OqpVQmdcqXzeNwhEAnz5PZAQnYwwz6+7GWIpHAyl3CToVTUi81wmJU6YMT9ef
3nzTocvInZnEor20203wbFVB7KTsdxWNYy12QLzndKe6OJWL8opGNzzdJZ858tvR
NKEQpcWnzmQA3KOCEmfjcvPVNVV9FZXM9V52H28hYC47PVNa1VFUck6V1a88pFrk
K1dQPdZwRvJUWPiXFvuc3y+VA/exB6ngWpN2GjwHwp2rQTP9qcgMv794quHmR/VI
6bmU2VwIziKxOl9hR1bo+81d67eNvYJ8fWh8iH8jD4m1oI1B6IKTzfYUHt0GCHBN
HSl3Pvw5APGPHfghGP9ty3Z2l2lPEsIEDox2QLy8MQKORWXBLSL+ElJeedmjgKn6
MCb8ldEhsIH5YyNqFcQ/YsfdFXaBRP0FONw/OtfCNWeQwHvw9k7ldBAb4BKnvNlm
IQEFKBj8NtzmEBM6g16BGy/7MdYxzen/L9IfHk0R0yT7YdvZ6zx4UXJ05Uw+WkEY
IJZTBtAvwNQsjXlQojrB
=fcQk
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--
