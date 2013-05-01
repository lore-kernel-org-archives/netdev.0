From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Wed, 1 May 2013 05:07:34 -0500
Message-ID: <20130501100733.GA16115@gmail.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f182.google.com ([209.85.213.182]:49248 "EHLO
	mail-ye0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab3EAKHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 06:07:39 -0400
Received: by mail-ye0-f182.google.com with SMTP id q8so241446yen.13
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 03:07:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130428011232.GA4236@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 27, 2013 at 08:12:34PM -0500, Lance Lassetter wrote:
> On Fri, Apr 26, 2013 at 11:12:33PM -0500, Lance Lassetter wrote:
> > On Fri, Apr 26, 2013 at 10:50:18PM +0200, Francois Romieu wrote:
> > > Lance Lassetter <lancelassetter@gmail.com> :
> > > [...]
> > > > the box serves as a network router so it is causing abundant ne=
twork
> > > > traffic problems.
> > > >=20
> > > > any debugging i could help you with, please let me know.=A0 als=
o if there
> > > > is a possible solution, please let me know.
> > >=20
> > > Is it a regression and / or an Asus M5A97 system ?
> > >=20
> > > The XID lines that the kernel printed when the r8169 module gets =
loaded
> > > may help.
> > >=20
> > > --=20
> > > Ueimor
> >=20
> > lance@annun10 ~$ dmesg | grep -i xid
> > [    6.370821] r8169 0000:03:00.0 eth0: RTL8168c/8111c at 0xffffc90=
000c70000, 00
> > :22:19:28:86:61, XID 1c4000c0 IRQ 45
> > [    6.371103] r8169 0000:04:09.0 eth1: RTL8169sb/8110sb at 0xffffc=
90000c7ec00,
> > 48:02:2a:07:90:45, XID 10000000 IRQ 20
> > lance@annun10 ~$
> >=20
> > i don't think it's a regression and it's a Dell XPS 625 with an add=
on r8169 so there are two r8169 cards in the system.  it is a testing f=
edora repository system though with vanilla mainline kernel.
> >=20
> > hope this helps,
> >=20
> > lance
>=20
> sorry for the lack of information thereof:
>=20
> the conventional processor name is AMD Phenom(tm) II X4 940 Processor
>=20
> i bought the computer back in like 2008, sorry.
>=20
> it's an AMD 790FX motherboard chipset for eth0 (r8169i driver)
>=20
> eth1 is a Roswell RC-404 PCI adapter (r8169 driver)
>=20
> if regression means it didn't used to happen and now it's happening w=
ith a newer Linux OS/kernel then yes.  if regression means something di=
fferent, i'm not sure.
>=20
> i think it started with my installation of Fedora 18 which began with=
 kernel 3.6 or 3.7, i really can't remember. it might have started with=
 kernel 3.8.
>=20
> before then all was OK.
>=20
> hope this helps.
>=20
> Lance Lassetter

Ueimor,

Any luck with this?

Regards,

Lance
