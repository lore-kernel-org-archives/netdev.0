From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] Bluetooth: Silence static checker warning.
Date: Wed, 29 Feb 2012 22:16:06 +0300
Message-ID: <20120229191605.GB22598@mwanda>
References: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QTprm0S8XgL7H0Dt"
Cc: marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:29837 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2B2UZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 15:25:09 -0500
Content-Disposition: inline
In-Reply-To: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QTprm0S8XgL7H0Dt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 29, 2012 at 10:36:57PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>=20
> Silencing Static checker warning.
> 1. Endian warning

It's not an endian warning, it's an endian bug.  This code won't
work on big endian systems.  Don't mix bugfixes and other changes.

Probably at some point someone will be updating their kernel for
an embedded platform and they'll do a "git log --pretty=3Doneline" and
they'll notice your endian fix and decide it's super important to
them.  Right now it's hard to find.

regards,
dan carpenter


--QTprm0S8XgL7H0Dt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPTnl1AAoJEOnZkXI/YHqRVnUQAJNniV+rYnA0u4/Q15rKd8NG
NE9qhnPl8J5SX7T/AtsZzAhK2I9ApwM4f15EXMYYTFFanFzlO8uD+yzn9gTLqRGH
vPyplTVRZ1clBURAB5jnfge3KTsVgYL3k7rMA54Fu6EozjTYTn+mBMP4HyDrk8WE
GqFCsoZU+cKrENJjfOLw6KX+cZRpLlKXixnlHfvo0iz7kO4S6/3ffX65ykcvm63C
1+Wvdy+q629XHcUILWXnwQtLVgdwnyY9/pZvtBFHCArwajxxWecbRQXWjILO6afO
cXyE2SR1I/8uWMEHwz3pTQfttt4X32kXJv63K77ptVunn3i/138X2S6NG9wVJxIO
SqawQjZbhpBTpxvPShUxWeOgiT8XN8Ermu0CqbayJC5AcwSvZRKfPpESaXyuSD2d
RIjycqRvAbDul38Pxepc/eTLYF5hZ6fjTzwg3UhS9kjEf0h+juNNX1y0Exm87jbP
UQLGsywIWSvAF0zwUzlzeiO030KBsuUU8y2cqXjLQDikyK7t67Y1mbo3PI5Ayk1k
Ag51jSb/3/t+Tf6wy4kHqE+rjFH87+eMeYsBEBc+58P8Grz3KRry66hXIwjTX4gp
mqCDJ+niqjIDrF+jsVmaQ66XmUAUouoVMAyQKMyt6bpShOwjD4qIedDScSnVNJ8c
MxOx69QozgPh4XyER386
=4C6b
-----END PGP SIGNATURE-----

--QTprm0S8XgL7H0Dt--
