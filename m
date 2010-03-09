From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] ar9170: fix for driver-core ABI change
Date: Wed, 10 Mar 2010 09:08:27 +1100
Message-ID: <20100310090827.096134f5.sfr@canb.auug.org.au>
References: <20100309104221.aedc5e7e.sfr@canb.auug.org.au>
	<20100309125245.c25e5ca4.sfr@canb.auug.org.au>
	<4B968CA2.4040000@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__10_Mar_2010_09_08_27_+1100_H4EZ2_FZvyHQX9rP"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:42395 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785Ab0CIWIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 17:08:32 -0500
In-Reply-To: <4B968CA2.4040000@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__10_Mar_2010_09_08_27_+1100_H4EZ2_FZvyHQX9rP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Stefan,

On Tue, 09 Mar 2010 19:00:02 +0100 Stefan Richter <stefanr@s5r6.in-berlin.d=
e> wrote:
>
> Stephen Rothwell wrote:
> > Greg tells me that the semaphore to mutex change didn't go into Linus'
> > tree.  However, this patch can still be applied as the device_lock/unlo=
ck
> > primitives did go in.  I guess that the include of mutex.h is not neede=
d.
>=20
> An #include <linux/device.h> seems to be in order though.  It is pulled
> in via linux/usb.h and this is surely not bound to change anytime soon,
> but still.

Damn! Caught by my own "Rule #1" :-)

Thanks.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__10_Mar_2010_09_08_27_+1100_H4EZ2_FZvyHQX9rP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuWxtsACgkQjjKRsyhoI8xTTACguLoq3b4GVnlTapZTwWGBf3iu
7ucAn1Krfd/LAY8FF4/k0s0yjXQxbaUs
=Yc/u
-----END PGP SIGNATURE-----

--Signature=_Wed__10_Mar_2010_09_08_27_+1100_H4EZ2_FZvyHQX9rP--
