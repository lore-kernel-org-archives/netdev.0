From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 20:52:45 +0200
Message-ID: <1285872765.2615.1008.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
	 <1285796721.5211.156.camel@edumazet-laptop>
	 <20100930062419.GD86786@beaver.vrungel.ru>
	 <1285828432.5211.812.camel@edumazet-laptop>
	 <20100930122321.GA1575@beaver.vrungel.ru>
	 <1285850669.2615.426.camel@edumazet-laptop>
	 <20100930173732.GB4094@beaver.vrungel.ru>
	 <1285869782.2615.920.camel@edumazet-laptop>
	 <20100930181556.GC4094@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930181556.GC4094@beaver.vrungel.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 septembre 2010 =C3=A0 22:15 +0400, Alexey Vlasov a =C3=A9cr=
it :
> On Thu, Sep 30, 2010 at 08:03:02PM +0200, Eric Dumazet wrote:
> > > =20
> > > The last test were made already concerning such rx queue binding:
> > > # cat /proc/irq/60/smp_affinity
> > > 001000
> > > # cat /proc/irq/61/smp_affinity
> > > 010000
> > > # cat /proc/irq/62/smp_affinity
> > > 080000
> > > # cat /proc/irq/63/smp_affinity
> > > 800000
> > >=20
> >=20
> > Why 60, 61, 62, 63 ? This should be 753, 754, 755, 756
>=20
> I've got several similar servers, the interrups 60-63 are on
> that one that I can test now, so this isn't a mistake.
>=20

If you have a burst of 'LOG' matches, it can really slow down the whole
thing.

You should add a limiter (eg: no more than 5 messages per second)

http://netfilter.org/documentation/HOWTO/packet-filtering-HOWTO-7.html

	This module is most useful after a limit match, so you don't
	flood your logs.
