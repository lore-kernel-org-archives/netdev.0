From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2008-09-24
Date: Thu, 25 Sep 2008 14:27:45 +0200
Message-ID: <1222345665.10563.75.camel@johannes.berg>
References: <20080924231720.GD3639@tuxdriver.com>
	 <1222321622.2510.455.camel@debian.sh.intel.com>
	 <20080925114133.GA5044@tuxdriver.com>
	 (sfid-20080925_134212_618549_FDAECEF8)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7h1p5FZDt26W575v1jGm"
Cc: Zhu Yi <yi.zhu@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:36399 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbYIYM22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 08:28:28 -0400
In-Reply-To: <20080925114133.GA5044@tuxdriver.com> (sfid-20080925_134212_618549_FDAECEF8)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7h1p5FZDt26W575v1jGm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-09-25 at 07:41 -0400, John W. Linville wrote:

> > http://marc.info/?l=3Dlinux-wireless&m=3D122219037706528&w=3D2
>=20
> Is there an open bug report for that anywhere?  Is this something
> that real users (no offense to Johannes) are likely to hit?

Actually, I now think that we don't want the patch. It appears that when
this situation happens, the hardware has scribbled over memory elsewhere
(most likely because of wrong DMA programming) and in that case I
suppose we'd rather fail than corrupt disk buffers et. al.

johannes

--=-7h1p5FZDt26W575v1jGm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI24O9AAoJEKVg1VMiehFYm28P/16DzAPudMZvGFyLzmSXGWk7
TCihtPBvGHC/2st4jLP2CycXy35zkJ+zyuoWuAdriWGS9YSlY3oOkKh/dTXmNMe1
f2RNIpWjd+5uPld3fasVWdlorABwtGs4aZPqyeM/XswxfY3GraA+oR8ztELgt1Rr
se4Uet9Zx3ljfj+n0pXZgZN0jbQHz344z4czJWc7B7mC/ArvTxma9Y/vAfq2Ve0w
B+cEYsFQzGwYTKB800bS5yiAWYf9CZlOMlI4OhrUAmzNZzDMaM/w7+dh3xGzBGnw
tP5bOWENr6gff+hc8CzX/nele1pGLHtfdvIfcDWYhrMfwfdARpmGpqdzO2J4FDo8
JQEiJr6JyOEiPxNQUEQvCYzmwO3OsIIVzoftXNerPn/B6UcmxDrcaVGjSXdd+hvn
6bVob2+BWNEIKEVBcCVfdgsUZXRMPi+dW0G1x5eVgbPtk5+HkSG1OyDk+5WaZbYc
6SvvDhk2A8W617903lDicr8WQc3aJhrYFB572coVkAMRtAADYQQIbVmXQmMBFgWX
Vk/KxFw3R0webXfJ6WEEbWiCNuzSexX/JMpmas68QArQ9jKYc+4D4Zaw5ao0L6aH
W7agBxka4dLokvXWy/Y1tP2g3Oj/H2irOe7vhwVUDOjPLVTxHtCeo4oi8lANgjiz
/6KV+NJNEUOLB9dhRuxm
=OxFX
-----END PGP SIGNATURE-----

--=-7h1p5FZDt26W575v1jGm--

