From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: Kernel connector - userspace <-> kernelspace
	"linker".
Date: Fri, 24 Sep 2004 07:40:32 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095997232.17587.8.camel@uganda>
References: <1095331899.18219.58.camel@uganda>
	 <20040921124623.GA6942@uganda.factory.vocord.ru>
	 <20040924000739.112f07dd@zanzibar.2ka.mipt.ru>
	 <20040923215447.GD30131@ruslug.rutgers.edu>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8fpkCBNjFfMFdPaA8Oer"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040923215447.GD30131@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-8fpkCBNjFfMFdPaA8Oer
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2004-09-24 at 01:54, Luis R. Rodriguez wrote:
> RFC:=20
>=20
> Can and should we work towards using this as interface for drivers that
> need callbacks from an external (closed source) library/HAL?

As I mentioned to Richard Jonson, it can be considered as
ioctl. ioctl-ng!
Unified interface (as ioctl) can be used for any type of modules.
It is just a bit extended ioctl :)

And _yes_, it can be used to turn on/off binary-only callbacks.
Remember pwc - closed part can register callback and open part can
send message, or even closed part can register notification when
open part registers itself and begin to "trash the kernel".

I understand that it is not right way to include it is into the kernel,
but I personally do not understand how it is different=20
from just extended ioctl. It was designed to be usefull and convenient,
and it is.

BTW, any binary-only module can _itself_ create netlink socket
with input callback. And that is all - it will be absolutely
the same as above.

One may consider connector as yet-another-netlink-helper.

--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-8fpkCBNjFfMFdPaA8Oer
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBU5cwIKTPhE+8wY0RArB9AJ9BVtouc/+Y4NtRR36frbG5W/k/gACeKd9o
Va1gj+T3Fd5AXJOAOMWsLpU=
=mKmD
-----END PGP SIGNATURE-----

--=-8fpkCBNjFfMFdPaA8Oer--
