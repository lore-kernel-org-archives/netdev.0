From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] Revert "net: Support inclusion of
 <linux/socket.h> before <sys/socket.h>"
Date: Thu, 12 Nov 2009 03:38:55 +0000
Message-ID: <1257997135.2237.100.camel@localhost>
References: <1257991205.2237.73.camel@localhost>
	 <20091111.185124.22668587.davem@davemloft.net>
	 <1257995115.2237.90.camel@localhost>
	 <20091111.190924.27363037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-LyYnO2/B2as6CvexidiW"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	538372@bugs.debian.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40538 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbZKLDi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:38:56 -0500
In-Reply-To: <20091111.190924.27363037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LyYnO2/B2as6CvexidiW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-11-11 at 19:09 -0800, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Thu, 12 Nov 2009 03:05:15 +0000
>=20
> > <linux/netlink.h> will not compile for userland, because
> > <linux/socket.h> is no longer defining sa_family_t.  For userland, this
> > should be defined by <sys/socket.h>.
>=20
> Still, you still essentially have two choices:
>=20
> 1) Tell userland, sorry you need to include sys/socket.h before
>    other "socket stuff" and that means linux/netlink.h in
>    particular

Which is just nasty; headers should include everything they need.

> 2) Put a !__KERNEL__ sys/socket.h include in there, but that's
>    asking for trouble.

Indeed.

Including <bits/sockaddr.h> would get us exactly what we need, but
that's not meant to be included directly.

Ulrich, can you make any suggestions as to how we can resolve this?

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-LyYnO2/B2as6CvexidiW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASvuDRee/yOyVhhEJAQIsDA//bhhecTM+MRCMw9fuQVcZbiYpF/fLR/Cy
086azN1z2py/CeP9jBDrXUYLuPpqcftWcwVGr/KXU7vGXPq23dl0AFhV6RwxrPIv
knt5Hqm3UwkQW2Mr6ltsDpKzqaZ2WViIYfml0NGq7WlqD3Y9brdj7jrcIDqaLyu7
hqji0vaFnmkKCfZRFALg6TqMmyZYIdkx86GiajeBFnw4xOSE9GiSvCRdT8PL2lzR
Xv65zLC0pmkOz8Q1zdmXjkIAChJXoxozGNqBG3BPfnQqeR9Rm2DkNQeUZmyHI4xX
vg6eXVFZSxbj1Bj0+PryvKScRcVFGzTONAUk6E69rdK6gxR47F8EY8jl7S/NN019
8/aRYIKsMSqXsavjqEx2Irz8YU0od8ipTm0AdyCxY8FMR2SMgk3dDBjH6BIZgc6G
6yeBlgFDHHeR/wOfSLnvqpXcmZl9znbXgAG+n8gdIsQU87FBYeUi4dLTZkAHXHOC
HAoCHmi8sXk3EPVKcCkB3+rGXJtYvWWTiBEMEqygw4+SGbPVwAdfdyEBzBSzMAlw
sh4sq+TERE+GrJS1lJIK1+4WI9ygZ9KMpZ9rPs2IO1okJlnQPRYgu4Ialkx01zxV
mEPcTekqwEdF/XfzBQ81HFFuQzX3gKZzlmt583VdsSdviWSp5MPH+ufHAJ67kQAv
ueHRds1vZ5A=
=ODWE
-----END PGP SIGNATURE-----

--=-LyYnO2/B2as6CvexidiW--
