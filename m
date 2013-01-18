From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 23:20:17 -0500
Message-ID: <201301172320.19905.vapier@gentoo.org>
References: <201301161205.04502.vapier@gentoo.org> <50F75EA7.4060309@systemhalted.org> <20130116.221538.1756411165313441486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1496406.g15FtnhD6U";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: carlos@systemhalted.org, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, yoshfuji@linux-ipv6.org,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116.221538.1756411165313441486.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1496406.g15FtnhD6U
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 16 January 2013 22:15:38 David Miller wrote:
> From: Carlos O'Donell <carlos@systemhalted.org>
> Date: Wed, 16 Jan 2013 21:15:03 -0500
>=20
> > +/* If a glibc-based userspace has already included in.h, then we will
> > not + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq.
> > The + * ABI used by the kernel and by glibc match exactly. Neither the
> > kernel + * nor glibc should break this ABI without coordination.
> > + */
> > +#ifndef _NETINET_IN_H
> > +
>=20
> I think we should shoot for a non-glibc-centric solution.
>=20
> I can't imagine that other libc's won't have the same exact problem
> with their netinet/in.h conflicting with the kernel's, redefining
> structures like in6_addr, that we'd want to provide a protection
> scheme for here as well.

yes, the kernel's use of __GLIBC__ in exported headers has already caused=20
problems in the past.  fortunately, it's been reduced down to just one case=
=20
now (stat.h).  let's not balloon it back up.
=2Dmike

--nextPart1496406.g15FtnhD6U
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+M2DAAoJEEFjO5/oN/WBvl4P/iv9RM0G+SXCqbiaAyLNhX4a
FEE+N2ts5zsxMyc+i4l+YmTJJfbxSBk874uc+Xp8UB3lU68JtvGIcYmw2axQWrbQ
0DUVsvrwDJT/PQffEPsK1LEE4pscmroKnpZ99YrueVD9a8tZLlVsRu7kj/PUlwob
l+JIY6WZmJiABtoPnr0XC3V1AI0GZKnCZAkeq3hcT4B8tosOUr2nO1Z/MN/JNqum
A//LfSKb9q2RcQyJ9n6IO7MG8Rdq/LjFBKUZnUCShejgCSLkpGIIdpZpHMDCoSXC
ug0KtQRjwkRx+RJNpeudk2N7CxsN3jXI9FWsYgZK2EXef+Z+RGg3IVfKOSJGdqMj
GvbydkUXfCq8rTCy1TN0vyaKwG+RwR2MZuhnmJuQEYSKdC1JsMY6tw8HhxymhN5q
c2mqQ2eMDubrG8yk9JJQvr9NzfEi8zEeItU1n5EPVm2x1JVaVJgMXnkyKRt/BxEr
PTyzFk+SLCHYweftXjCILG+MMHiqNCGx6QYCi/S85mq3744Sr98kCU+7RHDY7THU
lZfXOV4ClF8SJCVW5DpT3a/XWW2mJkejvy6kpkYk289/ORvut8MPzrUXcZgRCHLi
Dbsm4r1xuBDvLUbGeJQxvsjWWo/qfipCXN9/nZH5x2Uf4f/IVnQOwDaNHFOdk+DY
jziPKOX2YygidtKfru+6
=p4sn
-----END PGP SIGNATURE-----

--nextPart1496406.g15FtnhD6U--
