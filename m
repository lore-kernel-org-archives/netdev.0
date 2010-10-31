From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [GIT] Networking
Date: Sun, 31 Oct 2010 10:19:07 +0100
Message-ID: <1288516747.4050.10.camel@localhost>
References: <20101030.183257.70183832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-mcACyMkCft0qJlwm2DIO"
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33645 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754299Ab0JaJTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 05:19:44 -0400
In-Reply-To: <20101030.183257.70183832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mcACyMkCft0qJlwm2DIO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 18:32 -0700, David Miller wrote:
> Last pull request before 2.6.37-rc1, I really wanted to get your
> sendto/recvfrom patch in here as well as the RDS fixes.
>=20
> I did a bunch of tests with the various I/O calls using different
> lengths, like 10, (2^31 - 1), 2^31, 2^32, and larger on 64-bit and it
> all seems to be doing the right thing at least with TCP and UDP.
[...]
> 7) RDS fixes from you and Andy Grover.
[...]

Aren't the generic length limiting changes (8acfe46 and 253eacc) also
supposed to cover the overflow issues with TIPC?  Or are those still
unfixed?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-mcACyMkCft0qJlwm2DIO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATM00hue/yOyVhhEJAQKtHA//WCvNNKmoFLpx1RqIVT9qy4H7UTpPnHUZ
hDpxSpOk5eP6ouSwi+fqwhtBCqB1BbEljeoXMzXKob4M5yTvYEGmugjQGc4V2MR5
Q/qAX+VtVyP419kHIJO6vFQn3S+6nOa0pkyRLu58Jeor+c2WGx3Qng9BCfbGBMjQ
W/vVKbyNH0XMSD6qBuIzgLLZrPrZniHY5LTsyNacFMOTXASwnDpe6Rq+jqqoCHqf
rjniXD9fKabRuX0pfvRlXDv4MUtB/fD4//9TR24zLOa7EjYcJUR/QCdNh5TVpEed
C+3O8t2RoMsGkPu6qiEn//5e3h8/9fBYZQz3uD1QYxeb+zmkBPdEGI3enpCZsoBC
zq+WDOrvJM8roLY2gBDuwyyyNGbWJe3u3aICuWAz7QByL5cYch6xW9wYKLG4Wd1h
5AepVNIBsS58hzm2txlrtxJxhgAQnfnwn3O9oZsskYDYv5TBqDMBZZpdVOZPOxoR
RTjQa+jsZKlDc3ShlcXZaUCW+K97Ug5KzrdsKKUUtdJ+4ZZg0jMQHlazIjko8N7y
3IxqR8E9QmiA/Z0cONliRh2CD8fFkmKNdInU+8Sl0GALrQElOlSVCm4/Tz3ua9L5
Lb9wlzaAiofBJtxO1RuFOsCWavf6U3WQvHieBEc+8ETGr5WS5eXlOxSdI0PrhV39
S+LiFPuHezA=
=SK2/
-----END PGP SIGNATURE-----

--=-mcACyMkCft0qJlwm2DIO--
