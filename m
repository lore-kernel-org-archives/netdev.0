From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: d80211: clean up some list and loop code
Date: Fri, 17 Nov 2006 00:42:36 +0100
Message-ID: <1163720556.3392.27.camel@johannes.berg>
References: <1163718270.3392.19.camel@johannes.berg>
	 <20061116234034.GA6127@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RvGsSlNVAmxGp3xiFn3t"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12000 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1424581AbWKPXoS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 18:44:18 -0500
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061116234034.GA6127@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-RvGsSlNVAmxGp3xiFn3t
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-16 at 15:40 -0800, Jouni Malinen wrote:

> Isn't "for (;;)" the standard way of doing infinite loops? Please don't
> change that.

In *BSD it is apparently mandated, but Linux doesn't seem to do that as
John pointed out. Personally, I find while (1) much easier to read but
really, there's one occurrence so ...

johannes

--=-RvGsSlNVAmxGp3xiFn3t
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVz3a6Vg1VMiehFYAQLzjw/+LYRElJ929J/WZnRV/NNuYDBc4Lbxy1aV
K2FzfG+dj6Q/01Z2u4NO1NF3S7lzelipxM2wwzvdG2buJTEdzk1hlC6dE19Yr1G9
CXZNr94NjbD8uYDpvdw1uUo1XG9XqP7J3F09n5y7X27HZtxCtyjiSjp/5q4YiGSp
s40IIq2SuC6xyzhtOVdK2NhBUPyWJ48RS/w6W52qpXPqWjTtR+Mqi89NPWgHZ5yW
8kwFKim5wfWbUbTFA3qQC/UMULB6QIXk/yFV1A/CzQ+ybD27c90ov1JBLUZ2Wgvm
HiAbyXoOgXA54msNztsQrh/cqdARtr3Pqb1JGieTyWkLoS4+cYbQ17Kk69/8TtzT
PEjSpOHmr0hmfBuZ+zh3+Tv9u/aJiC4yEMRy4J7El2+K3lF0lWx5ljY1aYzcgSWt
7eXOjbtwusXxZ96XpYGpkl3B3QrikAuv3o9ig7YCJ8E+wY9mTlFsBkxU7jY+wd2J
47QRToCIQ1rSvp5bJVD3F+kxidj2BSwTjGfrwmfYqJ3ZXtp91NBN3uWXbH1BY6P3
LnPUxVqQ28lUY5Cb9esXJw+3+lKdG3OSlD4H8pICnWSC36DcwGSdrw3pbTFBRY9s
5+VUmNNIRRceZcg//PrB86TXbOX2OvPz2hP/jT7s3g2u5Eh4XyUT9hac6jGt3dBp
H+RvqLGGCwQ=
=19sh
-----END PGP SIGNATURE-----

--=-RvGsSlNVAmxGp3xiFn3t--

