From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 04:28:19 -0500
Message-ID: <200801110428.20354.vapier@gentoo.org>
References: <477BD374.6060506@zytor.com> <4787221F.3030201@zytor.com> <200801110403.00003.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3726465.mHVUAyYmHU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42054 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757447AbYAKJ2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 04:28:22 -0500
In-Reply-To: <200801110403.00003.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3726465.mHVUAyYmHU
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 January 2008, Mike Frysinger wrote:
> On Friday 11 January 2008, H. Peter Anvin wrote:
> > Again, I don't particularly care about what they're named, but the whole
> > point is
> >
> > 	#include <linux/foo.h>
> >
> > if you want the subset and
> >
> > 	#include <linux/bar.h>
> >
> > if you want the whole set.
>
> i looked more at glibc/uClibc and my primary/original concern (and what i
> thought what David was raising and you confirming) was that building of
> glibc was broken and glibc headers would need updates.  that does not seem
> to be the case.  the breakage here is for packages that include both
> sys/socket.h (directly/indirectly) and linux/socket.h
> (directly/indirectly).
>
> due to the way the network headers depend on each other, this case is
> trivial to induce.  but i dont think linux/socket.h is any more special
> than the current retarded conflicts we have between the network headers
> from the libc (which are required by POSIX and beyond) and the kernel
> headers.
>
> > No libc specifics, and no feature test macros, which I think we can both
> > agree are uglier than hell.
>
> i think in general, all of the network related headers under linux/ are
> fubared for userspace.
>
> > I thought the naming worked out nicer with <linux/sockaddr.h>
>
> placing the sockaddr definitions into linux/sockaddr.h makes sense.

so there's no confusion, since the building of the libc itself and using pu=
re=20
libc headers are generally unaffected, and all of the network linux headers=
=20
are already screwed for userspace usage, i'm not against the proposed chang=
e=20
from Peter.  it doesnt really make the situation any better/worse.
=2Dmike

--nextPart3726465.mHVUAyYmHU
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHhza0AAoJEEFjO5/oN/WBJE4P/Aj2k3nuGgrrjwTGTdqSMwRy
Fzs44owEoeIMBdkecxzMqWjLqf7TM5QeWN3t4q7Wzf7JfYfXA1MjhGEZpAHhO6M9
knRgoQCkTwuSyJMZ7g53XpbN/+noqHKHKVnwO+d6mRouTSwEkipcCJBfmfnbjKbI
mgSnUI89JpITAQaa3KxOYGuBPaGkvAiwBpfAUNgM6FCXdH0BJS9VYzBLAFqGf39p
DnPunMYROKAHXrzm7nSyGacc8SvIyzZ54anl7BYZyD2UfVRuxZyDH8vbWDy/SyKS
E3aEkBB6jx+o/awMtf9AyTf8uiv46XsF/FGxfV4+n/T7LWEp5ljBTENrk+zqZtJ0
V1HuTUD4VylGC8/KqsRbYyIW8g7JWeWtgNmqR7cwvxoRn5uarDGfV8OePqbizJXn
NH8n/dLVX0Rh3xUzv7D11TTXM4XQ9u2mId+eJn5MIejGE9rt8fdyLRinoR/jeD2B
UEwc7Wub1PFD/apPgXcj+6L//W4wo14E9/0mMopMaBBCk2/FdZjm00lAOfBdVXaV
lmvFBty6L57OVDE5VoWPsuRhnQID9QF/INFspX8EcJK0M4gmDmPHTu3dhP4YNBEd
0JC8/Z1EWBABkqHtr3UdmrWjxnW811eXW4d1UCQWlK9Bdvo35XkV1XED41xWtG1A
NipLGVAD1xK0M83TsTFC
=5qEr
-----END PGP SIGNATURE-----

--nextPart3726465.mHVUAyYmHU--
