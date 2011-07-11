From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sch_generic warn_on (timed out)
Date: Mon, 11 Jul 2011 23:20:04 +0200
Message-ID: <1310419204.2860.11.camel@edumazet-laptop>
References: <20110711204834.GA4950@redhat.com>
	 <20110711.141701.1453197953333902027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49168 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab1GKVUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:20:10 -0400
Received: by wwe5 with SMTP id 5so4311960wwe.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 14:20:09 -0700 (PDT)
In-Reply-To: <20110711.141701.1453197953333902027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 14:17 -0700, David Miller a =C3=A9crit =
:
> From: Dave Jones <davej@redhat.com>
> Date: Mon, 11 Jul 2011 16:48:34 -0400
>=20
> > We've recieved quite a few bug reports in Fedora recently concernin=
g this warning in
> > sch_generic..
> >=20
> >             WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): trans=
mit queue %u timed out\n",
> >                       dev->name, netdev_drivername(dev, drivername,=
 64), i);
> >=20
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D702723 is our 'master=
 bug' that we're
> > duping all others against. It seems to be showing up on a variety o=
f different
> > hardware (r8169, atl1c, ipheth, e1000e, 8139too). Do all these driv=
ers need
> > fixing ? or is it just 'crap hardware' ?
> >=20
> > note that I've only been looking through fedora 15 bugs so far (whi=
ch is still on 2.6.38),
> > but looking at the commit log for sch_generic, it doesn't seem that=
 there's anything
> > obvious that needs backporting.
>=20
> It means the transmitter stopped sending packets for several seconds.
>=20
> I would track this on a per-device basis if I were you, instead of
> combining them all into one super-bug.

Last time I took a look (on one r8169 NIC), it wasnt clear if this coul=
d
be a PAUSE problem.


