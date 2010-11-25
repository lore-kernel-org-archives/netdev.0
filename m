From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 09:16:18 +0100
Message-ID: <1290672978.2798.151.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	 <1290666501.2798.84.camel@edumazet-laptop>
	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	 <1290668246.2798.93.camel@edumazet-laptop>
	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48931 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab0KYIQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 03:16:23 -0500
Received: by wyb28 with SMTP id 28so613151wyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 00:16:22 -0800 (PST)
In-Reply-To: <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 12:52 +0500, =D0=9C=D0=B0=D1=80=D0=BA =
=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
> ---------- Forwarded message ----------
> From: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=
=B5=D1=80=D0=B3 <socketpair@gmail.com>
> Date: 2010/11/25
> Subject: Re: Simple kernel attack using socketpair. easy, 100%
> reproductiblle, works under guest. no way to protect :(
> To: Eric Dumazet <eric.dumazet@gmail.com>
>=20
>=20
> 2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le jeudi 25 novembre 2010 =C3=A0 11:52 +0500, =D0=9C=D0=B0=D1=80=D0=
=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit=
 :
> >> Well, It seems, that patch likely will fix 100% CPU usage.
> >>
> >> But what about eating all available descriptors in kernel ? vulner=
ability ?
> >>
> >
> > It doesnt fix cpu usage actually, your program eats 100% of one cpu=
,
> > like the following one :
> >
> > for (;;) ;
> >
> > If you want not eat 100% cpu, I suggest you add some blocking calls=
,
> > like usleep(10000)
> >
> > for (;;) usleep(10000);
> >
> > Patch only makes sure kernel wont eat too much memory to store infl=
ight
> > unix sockets.
>=20
> I have attached source which proove, that loop not inside this
> program, but inside kernel.
>=20
> --

Better send a fix, now that thousand of people know how to kill a linux
machine.

Congrats.



