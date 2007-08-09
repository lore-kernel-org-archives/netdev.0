From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [RFC] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 9 Aug 2007 17:30:39 +0200
Message-ID: <20070809153039.GB4955@ff.dom.local>
References: <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <46B75DD4.5080709@redhat.com> <20070806190812.GD26868@elte.hu> <20070809145026.GB3064@ff.dom.local> <p738x8kg0dp.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Chuck Ebbert <cebbert@redhat.com>,
	=?iso-8859-2?B?PT9pc28tODg1OS0yP3E/IE1hcmNpbiCmbHVzYXJ6Pz0=?=
	<marcin.slusarz@gmail.com>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:59228 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S940212AbXHIPaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 11:30:06 -0400
Content-Disposition: inline
In-Reply-To: <p738x8kg0dp.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 06:04:34PM +0200, Andi Kleen wrote:
> Jarek Poplawski <jarkao2@o2.pl> writes:
> 
> > It seems, we can start to think about some preferred solutions,
> > already. Here are some of my preliminary conclusions and suggestions.
> > 
> > The problem of timeouts with some 'older' network cards seems to hit
> > mainly x86_64 arch, and after diagnosing and testing (still beeing
> > done) it's caused by resending level type irqs.
> 
> i386 interrupt code should be similar, except for the lack of 
> per CPU irqs, but that shouldnt' affect resending.
> 
> > 
> > Possible solutions:
> 
> We should probably at least add some statistic counters to the
> standard kernel to try to detect these cases.
> 
> > It looks like these changes are needed for this x86_64 only,
> 
> Why?

Maybe I missed something, but considering the popularity of i386
there was not so much of consistent reporting?! I was very surprised,
when I read a few days ago that Linus seems to think that this one
here is only an individual problem...

Jarek P.
