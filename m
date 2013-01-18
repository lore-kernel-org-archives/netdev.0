From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 23:34:06 -0500
Message-ID: <201301172334.09440.vapier@gentoo.org>
References: <201301161205.04502.vapier@gentoo.org> <201301172320.19905.vapier@gentoo.org> <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart19433096.2P4o9Qpuej";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, yoshfuji@linux-ipv6.org,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: "Carlos O'Donell" <carlos@systemhalted.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:45201 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754575Ab3AREaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 23:30:35 -0500
In-Reply-To: <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart19433096.2P4o9Qpuej
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday 17 January 2013 23:22:26 Carlos O'Donell wrote:
> On Thu, Jan 17, 2013 at 11:20 PM, Mike Frysinger <vapier@gentoo.org> wrot=
e:
> > On Wednesday 16 January 2013 22:15:38 David Miller wrote:
> >> From: Carlos O'Donell <carlos@systemhalted.org>
> >> Date: Wed, 16 Jan 2013 21:15:03 -0500
> >>=20
> >> > +/* If a glibc-based userspace has already included in.h, then we wi=
ll
> >> > not + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mre=
q.
> >> > The + * ABI used by the kernel and by glibc match exactly. Neither t=
he
> >> > kernel + * nor glibc should break this ABI without coordination.
> >> > + */
> >> > +#ifndef _NETINET_IN_H
> >> > +
> >>=20
> >> I think we should shoot for a non-glibc-centric solution.
> >>=20
> >> I can't imagine that other libc's won't have the same exact problem
> >> with their netinet/in.h conflicting with the kernel's, redefining
> >> structures like in6_addr, that we'd want to provide a protection
> >> scheme for here as well.
> >=20
> > yes, the kernel's use of __GLIBC__ in exported headers has already caus=
ed
> > problems in the past.  fortunately, it's been reduced down to just one
> > case now (stat.h).  let's not balloon it back up.
>=20
> I also see coda.h has grown a __GLIBC__ usage.

that file is just a pile of cruft :).  it's something that'd be rejected by=
=20
today's kernel standard as it's full of OS shim code.  "#ifdef DOS" ?  come=
on!

fortunately, coda is pretty uncommon, so this issue doesn't bite most peopl=
e,=20
and i've never bothered with it.  the same cannot be said of stat.h.
=2Dmike

--nextPart19433096.2P4o9Qpuej
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+NDBAAoJEEFjO5/oN/WBjRIP/0KtnOcLeZI6yzgUpOy0gfWq
vRFXaHkixchHhXBELj4ooxQnKkf1LiWG6vOwMRNubD22K+x6mzkHPhEbtOBRNmr2
s2XY49XFi1WZB+QFWuGcRMzhlb9M5NPq34wOHDrMz0yAkF3oifGM6Dw2PNBmtNkT
7Hwf8DRg9Nuxu8tOuRaWLgUaO/qqSc6PfK0gY2s/XnnT4WHNeH47w/eu2u6w1G1Q
stcRUpxWodVH+f71xuuuDr+F5i8GSJDdH9KY3M+hKedhMOtEFKiaHqcX/kbcWM/E
82WnFE5N9KFFoXaPSOZ1RKIU0qYa6GLdSkTtNwWXc12RorcB7Y/otvbJbmFR8lvz
auS50pqBIFsuNPybfY5uQq5jf6V1rqIyacHaB2uipunbkXkMPWykXFtCfljqnujW
Cgs5QqedIu/dAzEdmr6tgYF/rcrCW/yaIh75yvWzIpsrmOyUHRWVc2wMCBOF3tdU
2Wf4VHZZvWzc6THk0EhmGAxyqBzofsWlFUeyfkFhxqPCXLLZquV3w9qzZ7Kgoedv
XQ/XxnjJAMfBq7yi/blF7SC9EGzRCezckamg+o8NnxMFCQVg8PHWbEluqTIyjUHy
YEfe2AxvC6q/KdQdwq1P7W9AyskfiulX6HBMe43hdislJYYoT7Z1GJwq2JqTg0j4
oWOKQ83T8E7+iFj+6bkv
=ggV+
-----END PGP SIGNATURE-----

--nextPart19433096.2P4o9Qpuej--
