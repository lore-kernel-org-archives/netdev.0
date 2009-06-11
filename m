From: castet.matthieu@free.fr
Subject: Re: [PATCH] bc47xx : fix ssb irq setup
Date: Thu, 11 Jun 2009 11:23:45 +0200
Message-ID: <1244712225.4a30cd2154cdf@imp.free.fr>
References: <4A11DBD4.7070706@free.fr> <4A1ADBAE.6070101@free.fr> <200906110959.38132.florian@openwrt.org> <200906111009.15080.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: matthieu castet <castet.matthieu@free.fr>, linville@tuxdriver.com,
	Michael Buesch <mb@bu3sch.de>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, Daniel Mueller <daniel@danm.de>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:46007 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbZFKJY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:24:58 -0400
Received: from wmproxy1-g27.free.fr (wmproxy1-g27.free.fr [212.27.42.91])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 4A53F2D87D
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 11:24:57 +0200 (CEST)
In-Reply-To: <200906111009.15080.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Florian Fainelli <florian@openwrt.org>:
> Le Thursday 11 June 2009 09:59:36 Florian Fainelli, vous avez =C3=A9c=
rit=C2=A0:
> > Hi Matthieu, Michael,
> >
> > Le Monday 25 May 2009 19:55:58 matthieu castet, vous avez =C3=A9cri=
t=C2=A0:
> > > Michael Buesch wrote:
> > > > On Tuesday 19 May 2009 00:06:12 matthieu castet wrote:
> > > >> Hi,
> > > >>
> > > >>
> > > >> [1] http://www.danm.de/files/src/bcm5365p/REPORTED_DEVICES
> > > >>
> > > >> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> > > >
> > > > If this works on all devices, I'm OK with this. Please submit t=
o
> > > > linville@tuxdriver.com You can add my ack.
> > >
> > > Well I have only a wl500gd.
> > > I have submit it on openwrt project in order to test in more devi=
ces.
> >
> > It makes the IPsec core work on my Netgear WGT634U and I did not se=
e any
> > regression on a Linksys WRT54GS.
> >
> > Tested-by: Florian Fainelli <florian@openwrt.org>
>
> One minor thing, please remove the dump_irqs call, it is convenient f=
or
> debugging to print the IRQ routing, but I find it a little too verbos=
e for
> production. This can be a follow-up patch if you prefer not to respin=
 it.

Well all x86 does something similar, with acpi dumping the pci interrup=
t Routing
Table even in production kernel.
But it can removed if people don't want it.


Matthieu
