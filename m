From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Sat, 29 Mar 2008 13:50:55 +0100
Message-ID: <1206795055.22530.140.camel@johannes.berg>
References: <20080328000013.GA8193@codemonkey.org.uk>
	 <20080328.173414.22278840.davem@davemloft.net>
	 <1206752049.22530.105.camel@johannes.berg>
	 <20080328.180631.91055366.davem@davemloft.net>
	 <1206784948.22530.128.camel@johannes.berg>  <47EE3B8C.8090707@gmail.com>
	 (sfid-20080329_124640_019940_A386AF33)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oKb515x9hne8iyFX4ht0"
Cc: David Miller <davem@davemloft.net>, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34905 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbYC2MvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 08:51:06 -0400
In-Reply-To: <47EE3B8C.8090707@gmail.com> (sfid-20080329_124640_019940_A386AF33)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oKb515x9hne8iyFX4ht0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > When you call cancel_work_sync(), the work struct will be grabbed by th=
e
> > code (really __cancel_work_timer) and removed from the queue. That just
> > operates on bits and a spinlock, not locks held across the struct work
> > function execution, and ensures it is race-free without needing any suc=
h
> > locks
>=20
> ...
>=20
> > However, as I just tried to explain, cancel_work_sync() _is_ safe to ru=
n
> > while holding the RTNL because it doesn't need any runqueue lock.
>=20
> These issues are so seldom now that I forget these details each time
>=20
> "after use", so maybe I miss something again, but shouldn't this rather
> read something like this?:
>=20
> cancel_work_sync() _is_ safe to run while holding the RTNL against
> works which don't take RTNL.

Yes, indeed, I should have said that.

johannes

--=-oKb515x9hne8iyFX4ht0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+47LqVg1VMiehFYAQJ6xg/8D1uG3AJmIdFz56c34O9iG3M7d6Ezb4Ce
AYtEszcJYnbA+a3/5IRYOdGrni/geXHbD8q1Pgol+n3TBkGdJhkTmLGYXkRyHH/d
8PSKX9q2dHXB5bEUsdgWZsbzvT2gWxzm3pB7p0xLjrY/Sr9+xdkTl2uI418c2maj
CmGykT0QrJG4AOTQFWvtoz8zqOxA1PC4pINMujV3hw7qw6QXZY3jgcpdeqqd17l7
LgnGtFEHIBOltl58F+/WKeMYaXhT2xt6uovuEKxaOSCl5zUSXWaosNMFVKngVsTA
m9WDzFHHwHLnwNClvkf0SlGhj4AaifjgMqMTB8X4EUJiUZ2WfpjbyhJsZHk9Mxnq
d1kKgms3dYUBslAIodL+3S1BOtIwlzEl2KeDZtDcKNJR2U7O/vL7ZCFvxl10T3u7
hzg3pajF72QEh2LIRrTQFslMSxXzmDUbThGQanQClhiaCYTqfGjJC37FGZZxOPBK
a9fKl5g3oNMdtIZZznQ0P7PdN+xNIY+IuXOF74GklF4z0vzSYn9xDdn3cxzymlmI
PH6AqzL1KJ4Xr5AZcLiy/gyRWz9xESfPC0siwJsONTUCtvWzXNhJobN07T8/7AIm
whWgjL5Kgus+sxhmhftjO5jPivFU8ReHZ036P1mJLU6Ne7ahdrgCkqvjsheyYZYb
N1pX3PQR/1Q=
=uXU3
-----END PGP SIGNATURE-----

--=-oKb515x9hne8iyFX4ht0--

