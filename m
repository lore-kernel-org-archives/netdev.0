From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Fri, 07 Jan 2011 03:41:11 +0100
Message-ID: <1294368071.2704.49.camel@edumazet-laptop>
References: <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	 <20101213224510.GB17400@mcarlson.broadcom.com>
	 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	 <20101214191500.GD19951@mcarlson.broadcom.com>
	 <1293901393.2535.49.camel@edumazet-laptop>
	 <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
	 <1293984348.2535.101.camel@edumazet-laptop>
	 <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
	 <1294356887.2704.13.camel@edumazet-laptop>
	 <1294363201.2704.19.camel@edumazet-laptop>
	 <20110107022912.GA17757@mcarlson.broadcom.com>
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
In-Reply-To: <20110107022912.GA17757@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 06 janvier 2011 =C3=A0 18:29 -0800, Matt Carlson a =C3=A9crit =
:

> Hi Eric.  Sorry for the delay.  I was under the impression that your
> problems were software related and that you just needed a revised
> version of these VLAN patches I was sending to Michael.  Is this not
> true?
>=20
> Having a hardware stat increment suggests this is a new problem.
> Maybe I missed it, but I didn't see what hardware you are working
> with and whether or not management firmware was enabled.  Could you t=
ell
> me that info?
>=20

Hi Matt

I started a bisection, because I couldnt sleep tonight anyway :(

14:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S
Gigabit Ethernet (rev a3)
	Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapter
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 43
	Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
	Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
	[virtual] Expansion ROM at fdbe0000 [disabled] [size=3D128K]
	Capabilities: [40] PCI-X non-bridge device
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
	Kernel driver in use: tg3
	Kernel modules: tg3
