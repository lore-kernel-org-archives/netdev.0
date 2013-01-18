From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 23:14:31 -0500
Message-ID: <201301172314.34193.vapier@gentoo.org>
References: <1358316366.14898.8.camel@cr0> <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com> <20130116.164511.2027039182184636075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4524473.iPNIk8yRGl";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
 bhutchings@solarflare.com,
 yoshfuji@linux-ipv6.org,
 amwang@redhat.com,
 tmb@mageia.org,
 eblake@redhat.com,
 netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 libvirt-list@redhat.com,
 tgraf@suug.ch,
 schwab@suse.de,
 carlos@systemhalted.org
To: libc-alpha@sourceware.org
Return-path: <libc-alpha-return-36394-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <20130116.164511.2027039182184636075.davem@davemloft.net>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

--nextPart4524473.iPNIk8yRGl
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 16 January 2013 16:45:11 David Miller wrote:
> What would be really nice is if GCC treated multiple identical
> definitions of structures the same way it handles multiple identical
> definitions of CPP defines.  Which is to silently accept them.
>=20
> But that's not the case, so we need a different solution.
>=20
> Another thing to do is to use a new structure for in6_addr in kernel
> headers exported to userland.

the kernel already exports many types with a __kernel_ prefix.  i changed t=
he=20
kernel headers in Gentoo for a few releases (2.6.28 - 2.6.34) to do the sam=
e=20
thing to pretty much all the networking headers.  a few packages broke, but=
=20
the number was low, and trivial to fix (a sed would do it most of the time).

it's also trivial for userland packages to detect that they need to do this=
=20
sort of thing in a local header by using linux/version.h and a set of defin=
es=20
to redirect the new structure name back to the old one.

would be a lot cleaner to just break it and be done.
=2Dmike

--nextPart4524473.iPNIk8yRGl
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+MwqAAoJEEFjO5/oN/WBBskQAMOonwYlzAbcqbYCYHhxza41
qy82GlFB/k/qwL2ai4b9gdBmFjzvIlF3IM5UOqklp+k1LkGwPJjA8fSq3oXjB74L
YEtZYm0K8XLwN5PhiuXTRjjWAEnh2+f0KQovIjzHQ9ME7cLWkwjmTDr3SCMaz9d6
yPcyMQjp9enEe1nt+5/yPphWUfVZl79ipSuHaBdHrqE1oz2tYb2L/wdWQCmZ7HEM
MmJ2srZ2xOxsCH+v/jjuVKnDXSFyEfEVd0nwdVCNXYiAPeeFwlzkVqrKHwTLpSUI
Fx8zH09eklkx4gOMXxD8rh6ulXOfWs0Z64nYWAzLhiW4Xo8hh0wi3BQ7MFTb2w5I
mjllXC/Uq9IXQ1AOab1r/2yL/Axf2OW7yQxG2on5TPzaJotRF4mZXhAusE0S0Rqv
itpH0Apon+lapezytdMz49r28JW33lmApMXm5bWWwjNhvQDUaWr9IEAqJOqJJ1XL
hOLzqzFqQ4Fs++1g8t+IKmzB/4C2pcuSjFlBh193unjSoUONWsEIdLGczU6LIVco
65GO+OOUpkCgK2cLv6aBLywhAwzi02u53ZQ0N7QMI/LYJlg3rVE3Ikz0KoiO0pHn
6t2Bkv8IYHTT4SyxoZnRdzkyY81ffXMZkutbTHBOSqf2b1BbhUtTIZ2E5F27K1AY
msbPZjq4OYPX46UJ8zcx
=BmdQ
-----END PGP SIGNATURE-----

--nextPart4524473.iPNIk8yRGl--
