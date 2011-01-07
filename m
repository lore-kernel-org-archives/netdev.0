From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Fri, 07 Jan 2011 04:04:46 +0100
Message-ID: <1294369486.2704.53.camel@edumazet-laptop>
References: <20101214191500.GD19951@mcarlson.broadcom.com>
	 <1293901393.2535.49.camel@edumazet-laptop>
	 <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
	 <1293984348.2535.101.camel@edumazet-laptop>
	 <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
	 <1294356887.2704.13.camel@edumazet-laptop>
	 <1294363201.2704.19.camel@edumazet-laptop>
	 <20110107022912.GA17757@mcarlson.broadcom.com>
	 <1294368071.2704.49.camel@edumazet-laptop>
	 <1294368202.2704.50.camel@edumazet-laptop>
	 <20110107025930.GA17808@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110107025930.GA17808@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 06 janvier 2011 =C3=A0 18:59 -0800, Matt Carlson a =C3=A9crit =
:
> On Thu, Jan 06, 2011 at 06:43:22PM -0800, Eric Dumazet wrote:
> > Le vendredi 07 janvier 2011 ?? 03:41 +0100, Eric Dumazet a ??crit :
> > > Le jeudi 06 janvier 2011 ?? 18:29 -0800, Matt Carlson a ??crit :
> > >=20
> > > > Hi Eric.  Sorry for the delay.  I was under the impression that=
 your
> > > > problems were software related and that you just needed a revis=
ed
> > > > version of these VLAN patches I was sending to Michael.  Is thi=
s not
> > > > true?
> > > >=20
> > > > Having a hardware stat increment suggests this is a new problem=
=2E
> > > > Maybe I missed it, but I didn't see what hardware you are worki=
ng
> > > > with and whether or not management firmware was enabled.  Could=
 you tell
> > > > me that info?
> > > >=20
> > >=20
> > > Hi Matt
> > >=20
> > > I started a bisection, because I couldnt sleep tonight anyway :(
> > >=20
> > > 14:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM57=
15S
> > > Gigabit Ethernet (rev a3)
> > > 	Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapter
> > > 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 43
> > > 	Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
> > > 	Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
> > > 	[virtual] Expansion ROM at fdbe0000 [disabled] [size=3D128K]
> > > 	Capabilities: [40] PCI-X non-bridge device
> > > 	Capabilities: [48] Power Management version 2
> > > 	Capabilities: [50] Vital Product Data
> > > 	Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
> > > 	Kernel driver in use: tg3
> > > 	Kernel modules: tg3
> > >=20
> > >=20
> >=20
> > $ ethtool -i eth2
> > driver: tg3
> > version: 3.115
> > firmware-version: 5715s-v3.28
> > bus-info: 0000:14:04.0
> > $ dmesg | grep ASF
> > [    6.220577] tg3 0000:14:04.0: eth2: RXcsums[1] LinkChgREG[0] MIi=
rq[0]
> > ASF[0] TSOcap[1]
> > [    6.228586] tg3 0000:14:04.1: eth3: RXcsums[1] LinkChgREG[0] MIi=
rq[0]
> > ASF[0] TSOcap[1]
>=20
> Thanks.  So management firmware is disabled.  This should be
> straightforward case.
>=20
> I'm wondering if I'm misunderstanding something though.  You said ear=
lier
> that VLAN tagging doesn't work unless you applied my patch.  Is this =
no
> longer true?
>=20

I dont apply your patch because Jesse said it was not a good patch ;)

Maybe I missed something and it must be applied ? Problem is : current
Linus tree now includes net-next-2.6 and vlan doesnt work. You should
resubmit it perhaps ?
