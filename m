From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: (usagi-users 03222) Re: support of IPv6 by NFS
Date: Tue, 01 Mar 2005 18:18:49 +0100
Message-ID: <1109697529.17484.37.camel@firenze.zurich.ibm.com>
References: <42243F8D.5030302@bull.net>
	 <200503010744.38339.Info@Quantum-Sci.com>
	 <1109689712.17484.6.camel@firenze.zurich.ibm.com>
	 <20050301161905.GD22324@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-W6Xjqd05xD/Sh1PKo+6c"
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050301161905.GD22324@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-W6Xjqd05xD/Sh1PKo+6c
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-03-01 at 17:19 +0100, Olaf Kirch wrote:
>On Tue, Mar 01, 2005 at 04:08:32PM +0100, Jeroen Massar wrote:
>> > There is no Linux 6to4=20
>> >UDP tunnelling app, but there should be, because this is such a common=20
>> >problem.  (As I understand, Teredo is Winduhs-only, and is not supporte=
d by=20
>> >most tunnel operators)
>>=20
>> The protocol for Teredo is open and can be implemented at will:
>
>Except that it's quite horrible,

It needs to be horrible as it needs to cross horrible NAT's.

> and it requires a centralized broker,

Doesn't every tunneling method require this? Or is 6to4 anycasted and
thus not central?

Do note that you can setup your own Teredo relay, see the docs at the
Miredo site for more information.

>and IIRC it also makes assumptions about the way your NAT implementation
>assigns ports.

It expects a Cone NAT (or was it the other thing?). The functionality
for the others where taken out because of 'security' concerns from some
people.

Greets,
 Jeroen


--=-W6Xjqd05xD/Sh1PKo+6c
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQBCJKP5KaooUjM+fCMRAvRhAJ4o8IBuLj1o3Hw1dTAoCwIjLoIrKgCgi5KG
INtpU/lvftq1ne3rFg9UqBo=
=RBR4
-----END PGP SIGNATURE-----

--=-W6Xjqd05xD/Sh1PKo+6c--
