From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:261
 dev_watchdog+0x249/0x260()
Date: Fri, 26 Mar 2010 15:34:10 +0100
Message-ID: <1269614050.2839.77.camel@edumazet-laptop>
References: <4BA7D897.9050407@web.de>  <4BACC1FD.3000609@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lee <lee-in-berlin@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63889 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab0CZOeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 10:34:15 -0400
Received: by bwz1 with SMTP id 1so1852094bwz.21
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 07:34:13 -0700 (PDT)
In-Reply-To: <4BACC1FD.3000609@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 mars 2010 =C3=A0 15:17 +0100, Lee a =C3=A9crit :
> Hi again,
>=20
> As this mail went unanswered, did I forget anything? Was it too verbo=
se?=20
> Should I file a bug report on bugzilla.kernel.org instead?
>=20
> Regards,
> Lee
>=20

Well, many problems with rtl8169, unfortunatly.

You could try Francois patch :

http://www.spinics.net/lists/netdev/msg124131.html



> On 22/03/10 21:52, Lee wrote:
> > Hi everyone,
> >
> > I get a kernel oops on 2.6.32.10 when I use an rt73usb WLAN stick w=
ith
> > hostapd 0.6.10. It's bridged with one of my ethernet (r8169) interf=
aces.
> > When I have the stick plugged in without hostapd, the kernel oops
> > doesn't happen. It's not easily triggered, it usually happens withi=
n a
> > few hours of use with hostapd. I have about a dozen of those from w=
hile
> > tracking this bug down, if needed.
> >
> > Everything seems to work fine (before and after the oops), but at l=
east
> > on one occasion I had a large delay on my ssh line when the oops ha=
ppened.
> >
> > I have no idea what is causing this, but will happily test any patc=
hes
> > that are handed in my direction :)
> >
> > Kernel oops, .config and hostapd.conf are attached. Please tell me =
if
> > anything else is needed to hunt down this bug.
> >
> > Regards,
> > Lee
>=20


