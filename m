From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] bc47xx : fix ssb irq setup
Date: Thu, 11 Jun 2009 10:09:12 +0200
Message-ID: <200906111009.15080.florian@openwrt.org>
References: <4A11DBD4.7070706@free.fr> <4A1ADBAE.6070101@free.fr> <200906110959.38132.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, Michael Buesch <mb@bu3sch.de>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Daniel Mueller <daniel@danm.de>
To: matthieu castet <castet.matthieu@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:46891 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760752AbZFKIJR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 04:09:17 -0400
Received: by ewy6 with SMTP id 6so1766730ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 01:09:18 -0700 (PDT)
In-Reply-To: <200906110959.38132.florian@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 11 June 2009 09:59:36 Florian Fainelli, vous avez =C3=A9cri=
t=C2=A0:
> Hi Matthieu, Michael,
>
> Le Monday 25 May 2009 19:55:58 matthieu castet, vous avez =C3=A9crit=C2=
=A0:
> > Michael Buesch wrote:
> > > On Tuesday 19 May 2009 00:06:12 matthieu castet wrote:
> > >> Hi,
> > >>
> > >>
> > >> [1] http://www.danm.de/files/src/bcm5365p/REPORTED_DEVICES
> > >>
> > >> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> > >
> > > If this works on all devices, I'm OK with this. Please submit to
> > > linville@tuxdriver.com You can add my ack.
> >
> > Well I have only a wl500gd.
> > I have submit it on openwrt project in order to test in more device=
s.
>
> It makes the IPsec core work on my Netgear WGT634U and I did not see =
any
> regression on a Linksys WRT54GS.
>
> Tested-by: Florian Fainelli <florian@openwrt.org>

One minor thing, please remove the dump_irqs call, it is convenient for=
=20
debugging to print the IRQ routing, but I find it a little too verbose =
for=20
production. This can be a follow-up patch if you prefer not to respin i=
t.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
