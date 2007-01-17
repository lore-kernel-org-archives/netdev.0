From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Tue, 16 Jan 2007 22:50:36 -0500
Message-ID: <200701162250.42731.flamingice@sourmilk.net>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1916317.L3QYan2UuS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:17121 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750969AbXAQDvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 22:51:18 -0500
To: Brandon Craig Rhodes <brandon@rhodesmill.org>
In-Reply-To: <87bqky759v.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1916317.L3QYan2UuS
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 16 January 2007 21:31, Brandon Craig Rhodes wrote:
> The attached patch, if applied to kernel 2.6.18, solves both problems.
> I am not very familiar with the conventions of kernel networking code,
> so there may be better ways of fixing this; but the patch should
> illustrate the general idea, and perhaps provides others in my unhappy
> situation with stable WPA connections until someone can provide a more
> authorized patch.
>
Please read <http://linux.yyz.us/patch-format.html>. You should CC=20
linville@tuxdriver.com as he is the maintainer of 802.11 things and can pus=
h=20
your patch upstream. Also, you should have a '\n' at the end of the new=20
printks.

Thanks,
=2DMichael Wu

--nextPart1916317.L3QYan2UuS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFrZ0ST3Oqt9AH4aERArAfAKCV724Rg2x9yRcUOTyZEFup2WV5ywCgw50N
OO1Y2JwmAXZmE3oHQYwjcQc=
=3a1b
-----END PGP SIGNATURE-----

--nextPart1916317.L3QYan2UuS--
