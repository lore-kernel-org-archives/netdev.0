From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Mon, 28 Oct 2013 16:04:48 +0100
Message-ID: <201310281604.48542@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1382971562.1542.6.camel@dcbw.foobar.com> <1382972215.17956.30.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2778838.sUdns2WpWe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:36736 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab3J1PEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 11:04:52 -0400
In-Reply-To: <1382972215.17956.30.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2778838.sUdns2WpWe
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 28 October 2013 15:56:55 Johannes Berg wrote:
> On Mon, 2013-10-28 at 09:46 -0500, Dan Williams wrote:
> > If the device doesn't actually *have* a permanent MAC
> > address, then it shouldn't be returning one via ethtool,
> > and should return an error for ETHTOOL_GPERMADDR.
>=20
> There's currently no provision for that, but I agree it would
> be better to do so.
>=20
> johannes

So what to do with devices which has MAC address stored in some=20
obscure place and there is userspace binary which can read it?

I think that there should be some way to tell kernel that *this*=20
is the permanent address and it should use it.

This is reason why I proposed patch which adding sysfs entry for=20
setting permanent address from userspace in wl1251 driver.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2778838.sUdns2WpWe
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlJufRAACgkQi/DJPQPkQ1KECACeNMxT+Rq5qW4t1CA69hwHLEkd
FdMAn0+XsNTX/OUaWrQLU8u6fOgFtY88
=TAVc
-----END PGP SIGNATURE-----

--nextPart2778838.sUdns2WpWe--
