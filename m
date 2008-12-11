From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [GIT]: Networking
Date: Thu, 11 Dec 2008 15:01:12 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812111500360.19338@vixen.sonytel.be>
References: <20081208.000655.211323914.davem@davemloft.net>
 <Pine.LNX.4.64.0812111344580.10515@vixen.sonytel.be> <200812110821.00002.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756875AbYLKOBa@vger.kernel.org>
In-Reply-To: <200812110821.00002.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Dec 2008, Paul Moore wrote:
> On Thursday 11 December 2008 7:50:23 am Geert Uytterhoeven wrote:
> > On Mon, 8 Dec 2008, David Miller wrote:
> > > Here are the pending net fixes:
> > >
> > > 6) netlabel OOPS'er fix from Paul Moore.
> > >
> > > Paul Moore (1):
> > >       netlabel: Fix a potential NULL pointer dereference
> >
> > This introduced:
> > | net/netlabel/netlabel_unlabeled.c:567: warning: 'entry' may be us=
ed
> > | uninitialized in this function
> > | net/netlabel/netlabel_unlabeled.c:629: warning: 'entry' may be us=
ed
> > | uninitialized in this function
> >
> > which may still oops, if the uninitialized entry pointer is
> > dereferenced (in case list_entry =3D=3D NULL).
>=20
> Hi Geert,
>=20
> First of, a quick question: what version of gcc are you using?  I'm=20
> using gcc-4.3.2 and I don't get this warning/error.  Regardless, I'll=
=20
> send out a patch later today which should resolve the warning.

I'm using an m68k cross-compiler, built from Debian sources:

| gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =C2=B7 Da Vincilaan 7-D1 =C2=B7 B-1935 Zaventem =C2=
=B7 Belgium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =C2=B7 RPR Brussels
=46ortis =C2=B7 BIC GEBABEBB =C2=B7 IBAN BE41293037680010
