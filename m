From: Ben Hutchings <ben@decadent.org.uk>
Subject: atl1c fails to force 100 full duplex
Date: Wed, 30 Mar 2011 23:10:45 +0100
Message-ID: <1301523045.10056.94.camel@localhost>
References: <AANLkTi=JDec_BTNLEX5AFnK6+BvjDPEN5PZw=QJ3M5XG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-zO1AaXKNfHoE43Syzgox"
Cc: luca boncompagni <lbonco@gmail.com>, 616081@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44171 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933171Ab1C3WKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 18:10:54 -0400
In-Reply-To: <AANLkTi=JDec_BTNLEX5AFnK6+BvjDPEN5PZw=QJ3M5XG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zO1AaXKNfHoE43Syzgox
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-03-02 at 12:46 +0100, luca boncompagni wrote:
> I can't get more 100FD from my network card when running on 2.6.37, if
> I boot on 2.6.32 it works fine.
>=20
> If i try to use mii-tool eth1 -F 100baseTx-FD I get the warning at the
> end of dmesg.

This is the usual TX watchdog warning.

> If I try to use ethtool I get no warning but it does not set full duplex.
[...]

Luca later reported that this is still broken in 2.6.38.  His full bug
report is at <http://bugs.debian.org/616081>.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-zO1AaXKNfHoE43Syzgox
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATZOqYOe/yOyVhhEJAQratw//XoApXPyLqL6ulj4zjYqcqfFOxID905yL
/3+C7BWgRE9ssr+LVfGc7xNiTydWse1XMvg1sx8VAAbdeKa5QhgT97/avD8hwCgF
X7ZU6DjpgWoQpxvYaBubj8mkzW2QX0k3wzRPQq85fjJfF41HAxNKVlG7xwBN8JhO
VYbAC8wqK8rgrad29EWmia1qa4KC6YJr99fHqiWjv79oB2gAt3rXa6nH+skMdTsB
VAABPVwv05Uj3xaOT82GIVTAxDSNbTwRvqPVzvJSPUBEksa1dndAWWLxyo+uHCoF
N8u5urUd4qoxFXSPOJfOGkcmb2UYimqvdLXwd5cXzECMxvskmlcQyvP34DimQYcl
FPzfuLARTWqY++67qD7K3rMSoPiyFbbbfB1pseptZssKnzzwvBLTqZbF7rgE0FSa
jM8+AaL0CItsYCts63xVSqG2j7bcqr8des9DKm7Osg+jmTty4qXxJo5/8PAmNCUd
GZoYCClGpgWQnUPRB2lWznG6XdZlwn/sn+htIQvMMqWa8gZndREOvqrZkA7zAN36
BrRTp3n3CFczFJJsQGhplSpnqpR7CIusj80ru6S3nZjNVSw043rE+9HSaL3apI/H
KO4/UMdJJPw4fDGSRbprsXqeZmNBDOHDVA47ogG9awN17+r8Lg35/rDqvlFZBr80
LFSNhRwV5xE=
=EiNX
-----END PGP SIGNATURE-----

--=-zO1AaXKNfHoE43Syzgox--
