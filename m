From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 22 Feb 2012 03:26:19 +0200
Message-ID: <6857224.s9gmvGgyqq@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <2604639.CVkfrWv5sk@localhost.localdomain> <1329845484.18384.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33399 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab2BVB1X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 20:27:23 -0500
Received: by bkcjm19 with SMTP id jm19so5848980bkc.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 17:27:22 -0800 (PST)
In-Reply-To: <1329845484.18384.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=C2 =F1=EE=EE=E1=F9=E5=ED=E8=E8 =EE=F2 =C2=F2=EE=F0=ED=E8=EA 21 =F4=E5=E2=
=F0=E0=EB=FF 2012 18:31:24 =E2=FB =ED=E0=EF=E8=F1=E0=EB=E8:
> > But maximum speed in 3.1.10 kernel (without this sysctl settings) s=
till
> > a bit more than in 3.2.7 - 11 MB/s instead of 10.3 MB/s.
> >=20
> > --2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-=
IMAGES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
> > 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 11,=
0M/s   in 3m 30s
> > 2012-02-21 19:13:55 (9,39 MB/s) - =AB/dev/null=BB saved [2066424512=
]
>=20
> Thats one measure, you'll have to make a lot of different measures to
> make this significant, preferably in a lab to rule out different
> external network conditions.

So, I did a couple of download tests from ftp3.de.freebsd.org with kern=
el 3.1.10.

Here traffic plot for net.ipv4.tcp_rmem=3D"4096 87380 897664":
http://img848.imageshack.us/img848/2425/net897664.png

Here plot for net.ipv4.tcp_rmem=3D"4096 87380 4127616":
http://img14.imageshack.us/img14/311/net4127616.png

And comparison of both plots:
http://img684.imageshack.us/img684/7163/netoh.png

The main notable difference is that with 4127616 there is
never stright line (when wget shows 11 M/s ) as with  897664.
Speed with 4127616 is close to 11 M/s but never constant.
I was able to reproduce this at least 3 times.
