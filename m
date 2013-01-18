From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Fri, 18 Jan 2013 00:27:02 -0500
Message-ID: <201301180027.06171.vapier@gentoo.org>
References: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com> <201301172314.34193.vapier@gentoo.org> <20130117.235524.2010232687612037902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2271619.9SQDBdVnEI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org, bhutchings@solarflare.com,
	yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, schwab@suse.de, carlos@systemhalted.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130117.235524.2010232687612037902.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2271619.9SQDBdVnEI
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday 17 January 2013 23:55:24 David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> > the kernel already exports many types with a __kernel_ prefix.  i chang=
ed
> > the kernel headers in Gentoo for a few releases (2.6.28 - 2.6.34) to do
> > the same thing to pretty much all the networking headers.  a few
> > packages broke, but the number was low, and trivial to fix (a sed would
> > do it most of the time).
> >=20
> > it's also trivial for userland packages to detect that they need to do
> > this sort of thing in a local header by using linux/version.h and a set
> > of defines to redirect the new structure name back to the old one.
> >=20
> > would be a lot cleaner to just break it and be done.
>=20
> We are not at liberty to break something that has legitimately
> compiled successfully for two decades.

i doubt there are code bases that have compiled successfully for that long=
=20
w/out being changed.  in fact, the kernel user headers (until recently) hav=
e=20
been a volatile mess requiring constant care & feeding of user programs to=
=20
keep compiling.  if anything, this would simply be maintaining the status q=
uo=20
for a bit longer.

> One thing you certainly don't have to be is happy about this header
> file situation, but you cannot use that dissatisfaction as
> justification to make the situation worse by breaking the build for
> people outside of the world you directly control.

i think you're making wrong assumptions about my position on the topic.  i=
=20
never said i was against cleaning up the kernel user headers (and in fact, =
you=20
can find many commits from me doing exactly that over the years in the kern=
el).
=2Dmike

--nextPart2271619.9SQDBdVnEI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+N0qAAoJEEFjO5/oN/WBXYQQAKBfGGxMvfL/Fc7VqdvjQ+h1
ueKUZasQRCfbdmVD9gWuMuxmN7iXt08or6o1anyAFyXS7XHDrY1AF/Mjbtnz9hxU
WzijugK1IU9E7aeK4DjzZERLMt1cH9sBXhoci/bYHPpIRI6xYxpeZDgBjWRg+/v4
YMXwl5M9OsOR93/h+RwIZACSb8ueiuluLhX3wMq1OtB1VmpPNh1KGpta97AqvpY9
6EMdhv8vFPImIu14cXrfYqL7eh3aR47crTbndhpZ2qYlX43+B91U6yuJLCpmYalv
2RgodJe1dvfhD2SSOIVwLBNsard44d9lFLO7JIU+G247ManMcZwvzZC+H+RYj5zK
Gfq/SNX+qTGVBToIdCORWZMBJS8/MDuRQoMxH2U8f8JCUKU44h+0qzkuOAxGncdp
BeH/7KECQvep0/MmgRkPD/5CssWaVnVjN6v1kdCjDpHt1L9WcbdbLyPzjUhXcI26
pwnB5iiqP8b9qzjmcGHZcUr883lbV2C7LX6i1XUScJEotECdymsuFSQndO2iIKCg
+/NPapMRf4VKevptfNpaWbqYO8GqGh5rXeeZ2GPT1y4b0WN6UuuYtQWtNGQPBNmY
vCUSrfmmDnGZrLGTq6xhLA+RRFE7z5XgWvzuY/kv/ZR+js3elVvwZCHlaxA5BssF
OEqiwvC/rwSaFPYuxaLD
=qzpw
-----END PGP SIGNATURE-----

--nextPart2271619.9SQDBdVnEI--
