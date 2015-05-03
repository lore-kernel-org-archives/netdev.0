From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Stable inclusion request: recvmsg/sendmsg userspace regression
 fix
Date: Sun, 03 May 2015 22:21:17 +0100
Message-ID: <1430688077.4113.111.camel@decadent.org.uk>
References: <54CBA338.1000207@suse.cz> <5525D4B3.6070400@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VL0QA7piBVqbaU2R75qh"
Cc: Michal Marek <mmarek@suse.cz>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ani Sinha <ani@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stable Tree <stable@vger.kernel.org>
To: Zefan Li <lizefan@huawei.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5525D4B3.6070400@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VL0QA7piBVqbaU2R75qh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-04-09 at 09:24 +0800, Zefan Li wrote:
> Cc: Ben
>=20
> On 2015/1/30 23:28, Michal Marek wrote:
> > Hi,
> >=20
> > please include
> >=20
> > commit 6a2a2b3ae0759843b22c929881cc184b00cc63ff
> > Author: Ani Sinha <ani@arista.com>
> > Date:   Mon Sep 8 14:49:59 2014 -0700
> >=20
> >     net:socket: set msg_namelen to 0 if msg_name is passed as NULL in
> > msghdr struct from userland.
> >=20
> > to 3.14.y and older trees, since it fixes a userspace regression caused
> > by commit dbb490b9 ("net: socket: error on a negative msg_namelen"). Th=
e
> > patch applies cleanly to all trees down to 2.6.32.y.
> >=20
>=20
> Queued up for 3.4. Thansks!
>=20
> It's still missing from 3.2.y, so cc Ben.

Queued up for 3.2, thanks.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-VL0QA7piBVqbaU2R75qh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVUaRUee/yOyVhhEJAQqlBQ/+Pb185mJ4jyapp4ro6fBz2DjtqZdqhfdj
7xjJWh+4jGvQA/c8vLQADiqBdxHvFMuQbbuTs2zKYKER9Pe2EHoDz203G7DxpSos
1I8LDwNXbNrmsj7ugZPlKIbctTnarrhXqOpikEyIYxo11o8jSgvE3pyn6ZTgdTG2
UD/zln3xtrYdTX35kRHJnwaA1jsdkzYeiodD9BaG054qLkHVZuR6Phwv2PveS/Tz
1nCFdMWhjlc13FONbUNAirCLhqWH8up1TVJbTgmZFQY+WNbVVoUdw7Jibh5hPRFe
1A7YdB07h67ulh436nk+wZ5ohVh2AcuSxsc9ENvWNLCtE+WZFDY31ygQR6QceOd1
2i9j4xl0UBG8eynufD/YboRh5Jb1eZJZBntlDxTgjirwKCSs8ZqbjPfSgm9jSfxM
t3AjAAKzEEVvjF1U3cXre7uZsrdHJUM1SoFOg+qPjMX6YKmPGyu08THhjlbYDsMt
7vwhJVW3SV/ghJjk2wKNltQ76PYC9yOAlYEF9Q+GeSViJMgHspACfUHOa4mEO4WL
bEee0jE30eWVElAVBGaHHRQymjhHSA1pYJTO8kwj27X6kZQyzh0EYNVfg+u2OfBs
z6IklOEG/ybq3m0OnDwZskqYDrS7YdBZDK5q0QI4vIwKjBWuwKtsOs9Wdn9gC4uJ
wQgJ8LeSXEY=
=MPwc
-----END PGP SIGNATURE-----

--=-VL0QA7piBVqbaU2R75qh--
