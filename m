From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix ethtool stats
Date: Wed, 21 Jul 2010 04:38:24 +0200
Message-ID: <1279679904.2492.20.camel@edumazet-laptop>
References: <1279646906.2498.103.camel@edumazet-laptop>
	 <AANLkTik7JrI3HrtvQRTgrRU30fFb2lrgGxUJsWXedBL0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46023 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932983Ab0GUCi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 22:38:28 -0400
Received: by wwj40 with SMTP id 40so1696143wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 19:38:27 -0700 (PDT)
In-Reply-To: <AANLkTik7JrI3HrtvQRTgrRU30fFb2lrgGxUJsWXedBL0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 15:06 -0700, Jeff Kirsher a =C3=A9crit =
:
> On Tue, Jul 20, 2010 at 10:28, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> > Note : I am currently unable to test following patch, could you ple=
ase
> > Intel guys test it and Ack (or Nack) it ?
> >
> > Thanks !
> >
> > [PATCH net-next-2.6] ixgbe: fix ethtool stats
> >
> > In latest changes about 64bit stats on 32bit arches,
> > [commit 28172739f0a276eb8 (net: fix 64 bit counters on 32 bit arche=
s)],
> > I missed ixgbe uses a bit of magic in its ixgbe_gstrings_stats
> > definition.
> >
> > IXGBE_NETDEV_STAT() must now assume offsets relative to
> > rtnl_link_stats64, not relative do dev->stats.
> >
> > As a bonus, we also get 64bit stats on ethtool -S
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  drivers/net/ixgbe/ixgbe_ethtool.c |   42 ++++++++++++++-----------=
---
> >  1 file changed, 21 insertions(+), 21 deletions(-)
> >
>=20
> Thanks Eric, I have added it to my queue.
>=20

Thanks !

By the way, my ixgbe conf doesnt like net-next-2.6 at all.
(No link is established in my fiber loop configuration)

current linux-2.6 git runs correctly, link at 10Gb, so there is a
regression somewhere.

As this machine is quite slow (I dont have anymore my Nehalem dev
machine, had to use an old setup), a bisection would take one month...



