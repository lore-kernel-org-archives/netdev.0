From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 10 Aug 2007 13:37:47 +0200
Message-ID: <20070810113747.GB3757@ff.dom.local>
References: <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local> <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com> <20070808114243.GC2426@ff.dom.local> <20070809091919.GB2423@ff.dom.local> <4bacf17f0708092333n17e0ba19jf2c769531610868d@mail.gmail.com> <20070810071038.GA1764@ff.dom.local> <4bacf17f0708100343r950cf90kbf826e2afc826df5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0708100343r950cf90kbf826e2afc826df5@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 12:43:43PM +0200, Marcin =A6lusarz wrote:
> 2007/8/10, Jarek Poplawski <jarkao2@o2.pl>:
> > (..)
> > I think, there is this one possible for your testing yet?:
> > Subject: [patch] genirq: temporary fix for level-triggered IRQ rese=
nd
> > Date: Wed, 8 Aug 2007 13:00:37 +0200
> I think I already tested this patch, but this thread is sooo big and =
I
> can't find my response...

I think it was very similar Ingo's patch, which after your testing
is in 2.6.23-rc2 now. I've moved return for level type irqs a little
later, and it works a new way only for "x86_64".

But, I think, now this patch is less important: if you find some time,
try mostly new Ingo's or Thomas' patches (latest possible versions).

>=20
> > If it's not a great problem it would be interesting to try this wit=
h
> > different CONFIG_HZ too e.g. you could start with 100 (I guess, you
> > tested very similar thing in 2.6.23-rc2 with 1000(?) already).
> My all tests were done on 2.6.22.1

=46ine! If it's not said otherwise this version should be appropriate f=
or
most of these patches. But, please, send your current configs on next
posibility (dmesg, /proc/interrupts and .config).

Bye (till monday),
Jarek P.
