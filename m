From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 22:32:01 +0200
Message-ID: <200911112232.01640.opurdila@ixiacom.com>
References: <200911112116.14103.opurdila@ixiacom.com> <200911112138.44074.opurdila@ixiacom.com> <4AFB19BF.9060901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:15256 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757407AbZKKUfA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:35:00 -0500
In-Reply-To: <4AFB19BF.9060901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 11 November 2009 22:08:31 you wrote:
> Octavian Purdila a =E9crit :
> > On Wednesday 11 November 2009 21:21:20 you wrote:
> >> From: Octavian Purdila <opurdila@ixiacom.com>
> >> Date: Wed, 11 Nov 2009 21:16:14 +0200
> >>
> >>> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> >>
> >> We're not doing this sorry.
> >>
> >> Dynamically size it at boot time or something, but a config
> >> option is out of the question.
> >
> > I don't think we can dynamically size it at boot time since it depe=
nds on
> > the usage pattern which is impossible to determine at boot time, ri=
ght?
> >
> > Would it be acceptable to grow it at runtime, in list_netdevice for
> > instance?
>=20
> It will be really hard, now we use RCU lookups...
>=20

OK, I've forgot about that :)=20

> What workload could reasonably need 1.000.000 hash slots, and 16.000.=
000
>  netdevices ?
>=20

And yes, I clearly get ahead of myself with that 20 bits.=20

Lets say we will max it to 14 for machines with over 1G of memory, woul=
d it be=20
acceptable to consume 64K out of that even if in most of the usecases w=
e will=20
only have a handful of interfaces?

So, on second thought, perhaps is better to leave this alone and have t=
hose=20
few users who need it to change NETDEV_HASHBITS themselves - its not li=
ke its=20
a too heavy patch to carry around.
