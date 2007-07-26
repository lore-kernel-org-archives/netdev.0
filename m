From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 26 Jul 2007 10:13:26 +0200
Message-ID: <20070726081326.GA3197@ff.dom.local>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com> <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu> <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:54675 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756757AbXGZIEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 04:04:13 -0400
Content-Disposition: inline
In-Reply-To: <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 26, 2007 at 09:16:10AM +0200, Marcin =A6lusarz wrote:
> 2007/7/25, Thomas Gleixner <tglx@linutronix.de>:
> >(...)
>=20
> I've tested Jarek's patch, 2 Ingo's patches (2nd and 3rd) and Thomas'
> patch (one patch at time of course) - all of them fixed the problem,
> but the last one flooded my logs with "Skip resend for irq 17". All
> tests were done on 2.6.21.3.
>=20
> I wanted to test them all on 2.6.22.1, but I didn't have enough time.
> I've verified only that 2.6.22.1 has the same problem. I can test it
> later, but I can report results back at beginning of next week.


So, everything is clear - any changes are good!
Except the signed-off ones...=20

Thanks Marcin,
Jarek P.

PS: Now, it seems to me Thomas could be the nearest. BTW, could somebod=
y
give me some tip, how these re-triggered interrupts are skipped on dev'=
s
reset before enable_irq?
