From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after
	random time
Date: Fri, 10 Aug 2007 11:08:33 +0200
Message-ID: <20070810090833.GA15121@elte.hu>
References: <JMJTMH$F1699B57C9B0E170ED337488612E649B@xandmail.com> <20070810083720.GE1764@ff.dom.local> <20070810084841.GA11086@elte.hu> <20070810090318.GG1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	"marcin.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38853 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761910AbXHJJIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:08:45 -0400
Content-Disposition: inline
In-Reply-To: <20070810090318.GG1764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> On 10-08-2007 10:05, Thomas Gleixner wrote:
> ...
> > But suppressing the resend is not fixing the driver problem. The 
> > problem can show up with spurious interrupts and with interrupts on 
> > a shared PCI interrupt line at any time. It just might take weeks 
> > instead of minutes.
> 
> Maybe I miss something but it's not the same!

_now_ i finally understand what you probably meant: because sw-resend 
worked and hw-resend didnt, it's hw-resend that is causing the breakage, 
not any driver or irqflow bug - correct?

	Ingo
