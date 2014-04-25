From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Fri, 25 Apr 2014 22:43:00 +0100
Message-ID: <1398462180.7767.211.camel@deadeye.wl.decadent.org.uk>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
	 <20140423153018.GA13717@breakpoint.cc>
	 <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
	 <20140423162712.GB13717@breakpoint.cc>
	 <20140424151748.GH1960@order.stressinduktion.org>
	 <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk>
	 <20140424163712.GJ1960@order.stressinduktion.org>
	 <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-H9S1iuKEfY74bjBP1CAf"
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36633 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751177AbaDYVnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:43:10 -0400
In-Reply-To: <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-H9S1iuKEfY74bjBP1CAf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-25 at 19:37 +0900, Lorenzo Colitti wrote:
> On Fri, Apr 25, 2014 at 1:37 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > The origins of this interface are in the openwall project. I assume
> > embedded devices were not that high up on their agenda.
>=20
> One of the original discussion threads I posted above has a link to a
> lengthy discussion on why the original designers of this code thought
> capabilities were not a good idea from a security standpoint.

Well, the use of gids for access control to global resources fits into
Android's security model very nicely.  I think it's quite unsuitable for
most other distributions.

> > We absolutely cannot abandon the interface as it already is in use by
> > android, as Lorenzo stated.
>=20
> Well, the fact that it's in use by Android doesn't mean it can't be
> made optional - Android can just turn the feature on in their kernels.
> It would be unfortunate if it were to be removed entirely.

Which I'm not proposing at all.

> > Will android switch to file based capabilities
> > in some time? Is that possible?
>=20
> I think Android does support file capabilities. But this socket type
> is not just for the ping binary. The fact that this socket type is
> available to any binary allows any application developer to write an
> app that can send ping packets. That seems like a useful capability
> for a diagnostic app.
>
> On the other hand, it seems to me that giving that same diagnostic app
> CAP_NET_RAW would be unacceptable from a security point of view since
> that app would now be able to sniff all traffic on the system, with
> obvious privacy implications. There are also the usual security
> concerns such as what if an exploit is discovered in the ping binary,
> etc. etc.
>=20
> What's the problem with this code? Is it just the 10KB in size?

It's 10K of code to do a very simple job... which is then disabled, so
that it's complete dead weight in most distributions.  (And it turned
out to open a new security hole for those that did enable it.)

As it happens, though, I just had to drop Debian's ixp4xx kernel due to
size limitations, and disabling ping sockets would fix that at least in
the short term.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-H9S1iuKEfY74bjBP1CAf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1rW5Oe/yOyVhhEJAQpWdQ//e8M3iQkUPUQC7YV1INoVWo5GAxoXYH6c
iy8BzIRyh5bENiI5pEeHxgWqOAhGyZphtKMN8YdDJdlrlwxYG3foyRQOIVdtz51e
cpCSmJ621QLiIvFTYEl4XZSp60s4BKPRndya0z7agmP+YfzndQZfyf0ZRTi/OW4T
9B+BRbNEDi8NIo7nEBxOeYU4sfvXFnlKSdrSfUza4FbcA7xJSquY+Cf4h3+fhwwC
wKTMH4KQ4P5xXKlP3wFkjZIyk8XSxMYLmUJiBFVy9KM1vt5WLkcw4fK48Nt8V1a8
9Wnf/BQd4+oW+11w40hiYzh2Vf4v/J3PSCtLxDYstCKs4Md8a7k0s5AzX6GY1O4g
h+ZAblw8LwBV/PDp1B3JEVhnja1pgRM5q+BKu/Ij5uIqfgRzVU3EN3SQJLRAx+YR
hMjvN81EXvbY0rjHuHsHa8kqHfBRNxpnE+BGuU5LmQ+H0w58HgrPLMqXn8sRDu72
4pM1bQD38IcwelCbznIgtbcasCjrOMGjgDaBSJQl93PUG+cye/2rZWE00hl1d5QJ
KLPwiVyxT0KVpado/Hmd5SFUuqgLkDC6fp2PoHRX6QdbC0+B6fy9QqJkvG5vEttt
wr96R9GyIJg1DEzFsmqLeDzOuxgtAbZ7rfTSLl73yhXhM7JkZU3H7++CYrAOZQCL
kUwo1WwwPVw=
=xYYs
-----END PGP SIGNATURE-----

--=-H9S1iuKEfY74bjBP1CAf--
