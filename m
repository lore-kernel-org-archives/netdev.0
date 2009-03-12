From: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Subject: Re: 3c59x: shared interrupt problem
Date: Thu, 12 Mar 2009 16:12:37 +0100
Message-ID: <20090312151237.50420@gmx.net>
References: <20090311224240.63430@gmx.net>
 <20090312143930.GA17955@newton.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53106 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755361AbZCLPMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 11:12:40 -0400
In-Reply-To: <20090312143930.GA17955@newton.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original-Nachricht --------
> Datum: Thu, 12 Mar 2009 15:39:30 +0100
> Von: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> An: Gerhard Pircher <gerhard_pircher@gmx.net>
> CC: akpm@linux-foundation.org, netdev@vger.kernel.org, shemminger@vya=
tta.com
> Betreff: Re: 3c59x: shared interrupt problem

> On Wed, Mar 11, 2009 at 11:42:40PM +0100, Gerhard Pircher wrote:
> >=20
> > > Your first report showed dnComplete as a pending interrupt source=
=2E
> > > Since the driver uses tx_interrupt_mitigation, this happens just =
if
> > > the tx ring is full. Could you please test the patch below? This
> > > disables tx_interrupt_mitigation, so the dnComplete interrupt wil=
l
> > > be triggered with every packet.
> > I disabled tx_interrupt_mitigation and tested it with and w/o the
> > patch for boomerang_interrupt(). The network transfer stalls in bot=
h
> > cases sooner or later.
> >=20
> > Here are two photos from the kernel output:
> > - no tx_interrupt_mitigation and patch for booomerang_interrupt():
> >
> http://boot.homelinux.org:8080/kernel/oops_boomerang_irq_tx_irq_mitig=
=2Ejpg
> > - no tx_interrupt_mitigation only:
> > http://boot.homelinux.org:8080/kernel/oops_tx_irq_mitig.jpg
> >=20
>=20
> Your pictures show just a message at shutdown. Are there any other
> unusual messages from the 3c59x driver in your logs? In particular I'=
m
> interested in "transmit timed out" messages.
Unfortunately no. But I had disabled debugging in the driver until now,=
 as
it slows down the network transfer considerably. I'll rerun the test wi=
th
debugging enabled.

I'm going to retry 'git bisect' next week. Maybe I find a way to compil=
e a
bootable image for older kernel versions.

Thanks!

Gerhard

--=20
Nur bis 16.03.! DSL-Komplettanschluss inkl. WLAN-Modem f=FCr nur=20
17,95 =BF/mtl. + 1 Monat gratis!* http://dsl.gmx.de/?ac=3DOM.AD.PD003K1=
1308T4569a
