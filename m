From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 01:23:37 -0500
Message-ID: <200801110123.38406.vapier@gentoo.org>
References: <477AF86E.1080309@zytor.com> <477BD374.6060506@zytor.com> <20080110.221615.188955433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2113276.fxHX4vkrtO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, netdev@vger.kernel.org, klibc@zytor.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53699 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbYAKGXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 01:23:40 -0500
In-Reply-To: <20080110.221615.188955433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2113276.fxHX4vkrtO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 January 2008, David Miller wrote:
> From: "H. Peter Anvin" <hpa@zytor.com>
> > Seems the most logical thing to do would be to break out the small
> > portion that everyone wants into <linux/sockaddr.h> or somesuch, and
> > then remove those ifdefs entirely.
> >
> > Proposed patch (still being tested) attached...
>
> I think this would clearly break existing glibc builds.
>
> I agree with fixing the ifdef checks, but not like this.

how ?  the large crap in linux/socket.h never made it into glibc builds, an=
d=20
the few things at the top which were relocated to linux/sockaddr.h are stil=
l=20
pulled in via linux/socket.h.  for glibc, the resulting '#include=20
<linux/socket.h>' should be unchanged.
=2Dmike

--nextPart2113276.fxHX4vkrtO
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHhwtqAAoJEEFjO5/oN/WBT1gQAMDkYYJh7G7pEkSpZVVg2Sej
dBzzD0cLzVssMQMt9rMQilHsJupoHUalhnp1hEQ/d3fPoVTltLyAobD2bEottQlq
BHy/8c+Jm+Nbc1FObPPRJQ502Y0yHaP/2WGc0/XE97xrM/v7ilckoRnbXBWmDOqQ
Q4+w9Sw2ruPIuVFPmTDc+s20tEZy7xOCMcnxVXkRnPlKzPP18HLO0/bQDaKo4GdW
q+ehuHUckwVxL/DZF5ledmiKZ/I9OG6ba8iU9nf20ccKF1sxM4gCd+jAilZVBwq6
5TmnK+J+aCz4HkGcNYH3BiooiQsLgdMSJMjtMqo8e4gcbaBIglFJQz0kc7aro3Uu
0qApZ1tIrllPvQhc1Ft9xSWhu4Y3y/mPSnKT0By+ixPiCD82ktfi1qlDugI3q6vi
WHpWADf1qXcx6bUWgMIZCziGvK+2bXu/lXLtBAZVL9lOSCs0YGjq+OOl+FUhjd32
azKZg05upw8Lir/SgJZLa3UrRNEgomRMYivUngjJups5E7jr7xtsZEDuUSILKGJc
01SU37SySpvvDlUu+39mSKN/OYOhMLs2N5zNu1w3k+sxprmR3LNpGNix7xzHZVbG
O5qmYgOiSHFvPviiu0/wsyoHoS3eTtab5eRRi+uEpWMSUwEbbV4XWvJCBRjRWgxW
gw7gYozQ0jS81TVAFODk
=NYSw
-----END PGP SIGNATURE-----

--nextPart2113276.fxHX4vkrtO--
