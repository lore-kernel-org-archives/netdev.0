From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 02:07:37 -0500
Message-ID: <200801110207.39736.vapier@gentoo.org>
References: <477BD374.6060506@zytor.com> <200801110123.38406.vapier@gentoo.org> <20080110.224749.66236050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3328509.efcKEF3B9j";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, netdev@vger.kernel.org, klibc@zytor.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59841 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbYAKHHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 02:07:41 -0500
In-Reply-To: <20080110.224749.66236050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3328509.efcKEF3B9j
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 January 2008, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> Date: Fri, 11 Jan 2008 01:23:37 -0500
>
> > On Friday 11 January 2008, David Miller wrote:
> > > From: "H. Peter Anvin" <hpa@zytor.com>
> > >
> > > > Seems the most logical thing to do would be to break out the small
> > > > portion that everyone wants into <linux/sockaddr.h> or somesuch, and
> > > > then remove those ifdefs entirely.
> > > >
> > > > Proposed patch (still being tested) attached...
> > >
> > > I think this would clearly break existing glibc builds.
> > >
> > > I agree with fixing the ifdef checks, but not like this.
> >
> > how ?  the large crap in linux/socket.h never made it into glibc builds,
> > and the few things at the top which were relocated to linux/sockaddr.h
> > are still pulled in via linux/socket.h.  for glibc, the resulting
> > '#include <linux/socket.h>' should be unchanged.
>
> Hmmm...
>
> Doesn't glibc include linux/socket.h?  If so, before it wouldn't get
> the sa_family_t et al. defines (because __GLIBC__ will be defined and
> it will be >=3D 2), but with your change it get those things.

oh, sorry, i see what you mean.  i was thinking in terms of crap removed (a=
s=20
that's what i'm after), not crap added (which is what Peter is after).  i=20
hadnt noticed that.  i dont know if it'll break glibc (and really, any othe=
r=20
sane libc).  if that is the case, then i think klibc here is the 2nd class=
=20
citizen to everyone else.
=2Dmike

--nextPart3328509.efcKEF3B9j
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHhxW7AAoJEEFjO5/oN/WBQWkQAKTNSoqbo6haQojAUKJgVlcG
H+EgVD0WnlxCH06k0R/eVBabbeD69FBb8C96WTY79avu75yExQYzb+n4Ou4L7BLJ
wtl2mLWlUc5Xdj175KTzuRJypviKnfBFSsBuSo/zmeERFzwNcZiGtwJ3LurGbtlh
UzFz68EQiMLOELpFPeCRsFQwPpBj5F7SSgC4y6tdCDCRYJol0eaiYY2BazB/2lHg
wnF5vOD06oeE5x4OGzK7I2BVnbRtAAbSUJLc9a6LtvDHUdpKo5fBET9aM7I4GMgh
4yO/H+gLna16ppirZp7u153DR8KaQlL1IKpY1oH7Ak8yiePtvLKN6i1d86JsAF3G
C67lQVIvqzkjHX+2VQ55odfaqfyzXgD+jE/CRqJ3G86nsdtNqbxHad8VQDhtWr3S
ZuJmDns7maGo1DB9WL9tzNF9GHoeCidpgKzwGCRrQbLQzLfCQethYCFAMqlgXvlF
0iJxU3C3m8fOzp53dZA/79TNmFgO5Q4B7AbMVJ2ol8et+7ifjHk6lq7DR0R0r5Gg
Pxb8JOVz5he8TkCKXiwMQFXqeIgpJs8JCSTNyATXxpjBHHAbKj7jHQNsERxYyFcb
6yYOe7Lg4Urovrf44grrUxZ5xxqK1m80qI98/ueWtd4XAxq+5M60i4pR7YB5dJqB
TaMHt+VvzXld8TfVNLeg
=F/xG
-----END PGP SIGNATURE-----

--nextPart3328509.efcKEF3B9j--
