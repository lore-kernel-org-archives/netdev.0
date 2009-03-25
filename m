From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Wed, 25 Mar 2009 00:06:43 -0700 (PDT)
Message-ID: <20090325.000643.55804624.davem@davemloft.net>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
	<20090324.234051.60226102.davem@davemloft.net>
	<2a27d3730903250005w2e773b01x1e9ec0606fc0e3d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754951AbZCYHGz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 03:06:55 -0400
In-Reply-To: <2a27d3730903250005w2e773b01x1e9ec0606fc0e3d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Li Yang <leoli@freescale.com>
Date: Wed, 25 Mar 2009 15:05:20 +0800

> On Wed, Mar 25, 2009 at 2:40 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Li Yang <leoli@freescale.com>
> > Date: Fri, 20 Mar 2009 17:04:29 +0800
> >
> >> The bridging device used a constant hard_header_len. =A0This will =
cause
> >> headroom shortage for ports with additional hardware header. =A0Th=
e patch
> >> makes bridging device to use the maximum value of all ports.
> >>
> >> Signed-off-by: Li Yang <leoli@freescale.com>
> >
> > Your driver must be able to cope with any amount of
> > available headroom, no matter what hacks we put into
> > the bridging layer.
> >
> > Please fix your driver, I'm not applying this patch.
>=20
> Ok.  But it's not good to reallocate every packet generated locally.
> Why not take this patch too?

Because as Stephen showed it didn't handle all cases.

Look at the patch I posted, that's the way to go.
