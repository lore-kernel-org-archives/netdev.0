From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Fri, 17 Feb 2012 00:08:57 +0200
Message-ID: <1843012.xoR1aAbfqy@localhost.localdomain>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <16215291.4ftfQWZto1@localhost.localdomain> <1329429573.5450.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44909 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620Ab2BPWJG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:09:06 -0500
Received: by bkcjm19 with SMTP id jm19so2519171bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 14:09:05 -0800 (PST)
In-Reply-To: <1329429573.5450.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=A7=D0=B5=D1=82=D0=B2=D0=B5=D1=80=D0=B3 16 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 22:59:33 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 23:49 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=
=D1=82 =D0=A7=D0=B5=D1=82=D0=B2=D0=B5=D1=80=D0=B3 16 =D1=84=D0=B5=D0=B2=
=D1=80=D0=B0=D0=BB=D1=8F 2012 13:19:58 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > > On Thu, Feb 16, 2012 at 12:54 PM,  <alekcejk@googlemail.com> wrot=
e:
> > > I still think it would be useful to have these three pieces of da=
ta
> > > for a slow/3.2.x transfer (from a geographically distant server) =
if
> > > you have a sec:
> > >=20
> > > - tcpdump of first 300 or so packets to see SYN/SYNACK options an=
d RTT
> > >=20
> > >=20
> > > - summary of overall throughput wget sees on that transfer
> >=20
> > --2012-02-16 23:33:30--  http://speedtest.tele2.net/1GB.zip
> > 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D>] 1 073 741 824 5,02M/s   in 3m 29s
> > 2012-02-16 23:36:59 (4,90 MB/s) - =C2=AB/dev/null=C2=BB saved [1073=
741824/1073741824]
> >=20
> > > This should help establish whether the receiver window is really =
the
> > > limiting factor in the slow cases.
>=20
> Is tweaking /proc/sys/net/ipv4/tcp_adv_win_scale changes the numbers =
?

Yes.
=20
> try 1, -1 or -2

With 1 and -1 maximum speed increased to 6,99 M/s, with -2 decreased to=
 3,3 M/s.
