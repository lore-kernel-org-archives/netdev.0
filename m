From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict +
 06xe/0xb7 [ipv6]
Date: Sun, 25 Apr 2010 19:08:31 +0200
Message-ID: <1272215311.2069.91.camel@edumazet-laptop>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>
	 <4BD45E68.4080900@example.com>
	 <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
	 <4BD46F9C.5060500@example.com>	 <1272213597.2069.32.camel@edumazet-laptop>
	 <j2p2d0a357f1004250955i59969a2cp9fd9eb9f3ef22d4b@mail.gmail.com>
	 <4BD4757E.8020503@example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, Sedat Dilek <sedat.dilek@googlemail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: piotr@hosowicz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51653 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab0DYRIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 13:08:37 -0400
In-Reply-To: <4BD4757E.8020503@example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 avril 2010 =C3=A0 19:01 +0200, Piotr Hosowicz a =C3=A9cr=
it :
> On 25.04.2010 18:55, Sedat Dilek wrote:
> > Rebuild ipv6 kernel-modules by:
> >
> > $ make M=3Dnet/ipv6
> >
> > ...and copied net/ipv6/*.ko and net/ipv6/netfilter/*.ko files manua=
lly
> > to the right place.
> >
> > Applied your patch (seen on netdev ML) already and booted into new =
kernel.
> > Works, thanks.
> >
> > Tested-by: Sedat Dilek<sedat.dilek@gmail.com>
> >
> > - Sedat -
> >
> > On Sun, Apr 25, 2010 at 6:39 PM, Eric Dumazet<eric.dumazet@gmail.co=
m>  wrote:
> >> Le dimanche 25 avril 2010 =C3=A0 18:36 +0200, Piotr Hosowicz a =C3=
=A9crit :
> >>> On 25.04.2010 18:31, Sedat Dilek wrote:
> >>>> [ CCing netdev ML ]
> >>>>
> >>>> Confirmed: The revert-patch [1] fixes the problem here.
> >>>
> >>> I confirm, I've built a git6 kernel and it works fine.
> >>>
> >>>> See also "Bug 15847 -  crash in inet6_csk_bind_conflict" [2].
> >>>>
> >>>> Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.c=
om>
> >>>
> >>> I added created and tested phrase in my archive. ;-) Thank you a =
lot. I
> >>> hope there will be no this error in git7.
> >>>
> >>
> >> Did you test the proposed fix ?
>=20
> Eric, but where to get the proposed fix as a patch? I looked at kerne=
l's=20
> bugzilla and there is no such thing. As for now I applied Sedat's=20
> reverse patch and now I am booted fine in git6 kernel.
>=20

I wont spend my Sunday time at filling bugzilla entries.

I sent a patch on netdev.

I finaly could test it (I have a very slow machine while traveling, and
compiling the thing took a *lot* of time)

Now back to family affairs ;)



