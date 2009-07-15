From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: deprecate print_mac
Date: Wed, 15 Jul 2009 20:35:26 +0200
Message-ID: <1247682926.10754.28.camel@johannes.local>
References: <1247671403.10754.8.camel@johannes.local>
	 <20090715.113156.120453022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-9WkvTyA8wofuC6DqnH+F"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53559 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbZGOSgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 14:36:02 -0400
In-Reply-To: <20090715.113156.120453022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9WkvTyA8wofuC6DqnH+F
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-07-15 at 11:31 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Wed, 15 Jul 2009 17:23:23 +0200
>=20
> > We've had %pM for long enough now, time to deprecate
> > print_mac() and remove the __maybe_unused attribute
> > from DECLARE_MAC_BUF so that variables declared with
> > that can be found and removed. Otherwise people are
> > putting in new users of print_mac().

> I think I'm going to apply this after John's next
> wireless merge to me for net-next-2.6

Sounds good. There was one more user in fcoe where I've sent the
conversion to the scsi folks, here:
http://marc.info/?l=3Dlinux-scsi&m=3D124767208229782&w=3D2

johannes

--=-9WkvTyA8wofuC6DqnH+F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKXiFnAAoJEODzc/N7+QmaMoAQAIgPeQNJ6ISwK44Nw5uMjqeG
N809/spnd//DoMIdYXIfuM+9TEee20YgV8G3R4CuuKQ+6t2j7wcMPlsKz+nO53kd
yoDznXO6APrHnUOgur3BT6ZwpDFK3J4cOOEy89/g5uhhIFPGOML8giU7XXpFxUzb
Y4rWs/nBShuARxILY75lTX6hq7Y1DTZEwwTAIiEWhfNekXJqzbnW7Wo+eG4l0IWz
j22JykXRUGcLv8LyrcyrL9QblMyuWsd4YVUWjiK5Lp/e9cCwYMN/y20dadMs+fv0
7hRU4345TwIkVPzSSgQPirpv10va3eKX9kSVaDKOqwfVCvl22jrydM9QA/wXl1JG
v+LeETC4ddSnu3Wa0aXKVK0vYVNffv6mSZufRNKQdeCgDK1RRl2Y4/neM+CTE7RX
munHJfiARzEfhLeHgmrH5V3JRW1SyFAj6Dao/pixRLSIB53DtawrAAed7TTJ2XVG
Yh1bzvuyL6/Fjp3hZcNffK2L0xlZPXmkQ5BFP3F6y5hG7bGeF/+1PFH/BAOGqefK
1IbL3u6FhwUyRcgMFiHcU0aVL530Y8G7rOXhP8r7c7vcHny+FQSjrwwwi9udMGN6
k1vp6Xh1leiSunCHPg4P5EFuuRZEVVRGW81wfIqJl/poffkVbPB+MITn5B2KdKof
9u98kPI0/pn7beq0vquc
=HPaK
-----END PGP SIGNATURE-----

--=-9WkvTyA8wofuC6DqnH+F--

