From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: RFC 3484 support
Date: Thu, 13 Nov 2003 15:12:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB40FE5.5040709@redhat.com>
References: <200311131007.NAA23770@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200311131007.NAA23770@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

kuznet@ms2.inr.ac.ru wrote:

>>1. use the existing kernel functionality and provide an interface to it
>>   which userlevel can use
>=20
>=20
> This interface is connect() for example. Essentially, connect() on
> datagram socket with subsequent getsockname() makes exactly this.

Wouldn't this require to set up a socket and connect it to each target
address?  The point of the whole source and destination address
selection is it to avoid making connections with addresses/via
interfaces which might have problems.  getaddrinfo returns a list of
addresses which a client program then tries in the order they are
provided.  The address which has the highest rate of success and the
highest quality for the connection should be tried first.  And all this
is subject to all the customization and configuration going in the kernel.

- --=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/tA/l2ijCOnn/RHQRAiYcAKCjgzJXwd/zV7KaWBUnaIqNEUdHrgCeKq5g
pQm7ViT1UChv0DtqKaxkdiY=3D
=3D/Jay
-----END PGP SIGNATURE-----
