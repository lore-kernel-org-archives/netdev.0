From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Fri, 05 Dec 2008 00:09:24 +0100
Message-ID: <1228432165.3970.2.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <200812021807.25873.inaky@linux.intel.com>
	 <1228381247.3197.16.camel@Friederike-PC.hoffi>
	 <200812041121.44265.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wbupCAl8QILOYc1Tk59l"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54016 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759170AbYLDXJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:09:32 -0500
In-Reply-To: <200812041121.44265.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wbupCAl8QILOYc1Tk59l
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-12-04 at 11:21 -0800, Inaky Perez-Gonzalez wrote:

> The implementation details are not the problem, there I totally agree
> with you. The problem is how to establish the cutline. What you are sayin=
g
> is exactly how I envision it to happen and the direction I'd like it to
> take, but I just don't want to do it until at least we have two vendors
> talking.

> > Here's where I disagree, obviously, I think you should at least define =
a
> > subset of the imaginable interface, which is, in my opinion, _much_
> > better than defining no interface at all and hoping for the next guy to
> > figure it out, which is unlikely to happen when you haven't started wit=
h
> > something the next guy can understand.
>=20
> No wait, I don't want guy #2 to define it--I want to work together to def=
ine
> it, to make sure it works for him and for me without having to throw to
> the garbage something I did on my own that won't work.

But, but, you have to throw away all your 'behind-the-private-call'
things anyway, at that point.

I think my point here really is that you're defining an API that's
intentionally private because you don't want to define a public one even
though that should be extensible enough. And then we get to the stuck
with the private API because all the userland uses it, and the next guy
will invariably implement it that way too, simply because you did and it
works that way and is much easier than getting it right (he'll just say
that because his is somewhat similar to yours he wants to wait for the
third implementation... ;) )

johannes

--=-wbupCAl8QILOYc1Tk59l
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJOGMhAAoJEKVg1VMiehFYZNgQAKIb1iLJ6vulM4lIqtbeb/67
Dds+d5Ie0pEZs2HT1cKc+MgQqhJhAgZKbX9tEs3TGCcHzPX4dYzlNZlV1Z8yEUvg
jMUK06de+tjEptiau32KQPFG9nkSnaDgczBAA++dslNBB+DdwmV0gCPNwKMos/es
hEqWtiyMWNY3kSC4LGC/HQq+AP30KKV6ZjUYcgrhdAONy8St9GQtktwlsCQqo+Sn
FOTs3TBl0V4GeBVytVMIabSJVumkKrojBUiDpCYRWeb6VeBd2i+YM8WR/WAYwA8D
JLwnojCtgaI4/Wai09AsmbLdWQ4HyTg56yyji7XuWOIEY8oWhfqksO/ZqRqB3UAv
HHOwD33m1dfyiNe9TpcbOsJAUUvGgcEMtwA0vN+os00wHqdRQYlJ8dvSG/4drvp9
rhRNsR0dOUi2fCECOlIuVrVm/CtvsOsyfzEEYsqxsOKBTqJVy7epvG6AHSF6h4Wx
RtWLguu2zzRXJMfjFkB0TO4iKRTlc0rr4eOxq1jl8seOU3TLuyfFNEdeT2+ApVCk
ZwJU3+sFxIJQC4wkgZAaMd9QbK84WrSb3PJntkrONHrXu3uAb+bXnrEPUxlYUso6
6FTqwZCzim4L21Owxgl/6GGWQLZMiCksC3igGcvylKxpqoNlUbj/0DnCu5S7RymF
tJOuUWuBv3YzJAc81MFF
=WRQA
-----END PGP SIGNATURE-----

--=-wbupCAl8QILOYc1Tk59l--

