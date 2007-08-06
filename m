From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: [patch (take 2)] genirq: fix simple and fasteoi irq handlers
Date: Mon, 6 Aug 2007 09:07:55 +0200
Message-ID: <4bacf17f0708060007t7c849ff1p5dbb07c614789617@mail.gmail.com>
References: <20070726081326.GA3197@ff.dom.local>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
	 <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
	 <20070731155843.GA7033@elte.hu> <46B20E47.6020403@googlemail.com>
	 <20070802201126.GA27000@elte.hu> <20070806060723.GA981@ff.dom.local>
	 <20070806061459.GA26046@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Gabriel C" <nix.or.die@googlemail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:40866 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbXHFHH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 03:07:56 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1689927wah
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 00:07:56 -0700 (PDT)
In-Reply-To: <20070806061459.GA26046@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/6, Ingo Molnar <mingo@elte.hu>:
>
> * Jarek Poplawski <jarkao2@o2.pl> wrote:
>
> > Subject: genirq: fix simple and fasteoi irq handlers
> >
> > After the "genirq: do not mask interrupts by default" patch interrupts
> > should be disabled not immediately upon request, but after they
> > happen. But, handle_simple_irq() and handle_fasteoi_irq() can skip
> > this once or more if an irq is just serviced (IRQ_INPROGRESS),
> > possibly disrupting a driver's work.
>
> nice fix. I think this is exactly the type of bug we were hoping to be
> able to identify and fix, and it could explain the regression in its
> entirety. The big question - does it fix Marcin's regression?
I'll try this patch tomorrow.

Marcin
