From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Mon, 19 Jul 2010 13:29:30 -0700
Message-ID: <1279571370.20559.25.camel@HP1>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
 <AANLkTikfEED5Hvt80G6EnMwPBByMuw4r1Xg2ITjuZ0eV@mail.gmail.com>
 <1279565231.20559.14.camel@HP1>
 <1279568875.2458.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Christophe Ngo Van Duc" <cngovanduc@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3862 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966583Ab0GSUaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 16:30:46 -0400
In-Reply-To: <1279568875.2458.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2010-07-19 at 12:47 -0700, Eric Dumazet wrote:
> Le lundi 19 juillet 2010 =C3=A0 11:47 -0700, Michael Chan a =C3=A9cri=
t :
> > On Mon, 2010-07-19 at 08:55 -0700, Christophe Ngo Van Duc wrote:
> > > So i've been able to do some test today:
> > > If I put the 2 interface in a bridge with no IP adress, the inter=
rupts
> > > are on 1 CPU
> > > If I put the 2 interface in a bridge with IP adress, the interrup=
ts
> > > are still on 1 CPU
> > > If I put the 2 interface outside the bridge with IP address,
> > > everything works fine the interrupts get spread on the CPU
> > >=20
> > > So the conclusion seems to be that when the bnx2 is put into
> > > promiscuous mode by the bridge, the RSS hash stop to work even if
> > > traffic is IP in nature.
> >=20
> > I did a quick test with bridging and saw no problem with RSS.  I di=
d see
> > this though:
> >=20
> > br0 received packet on queue 4, but number of RX queues is 1
> >=20
> > Looks like it is a warning message from RPS.
> >=20
>=20
> Christophe uses an old kernel, not RPS enabled ;)
>=20
>=20

Right, I'm reporting a related problem on a newer kernel with RPS
enabled.  And the fact that it is receiving packets on queue 4 shows
that RSS is working together with bridging.

I'll try to use an older kernel to see what happens later today.


