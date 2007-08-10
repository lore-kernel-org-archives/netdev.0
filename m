From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after
	random time
Date: Fri, 10 Aug 2007 10:15:53 +0200
Message-ID: <JMJTMH$F1699B57C9B0E170ED337488612E649B@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"mingo" <mingo@elte.hu>, "tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764040AbXHJIRW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So, we still have to wait for the exact explanation...
> 
> Thanks very much Marcin!
> 
> I think, there is this one possible for your testing yet?:
> Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
> Date: Wed, 8 Aug 2007 13:00:37 +0200
> 
> If it's not a great problem it would be interesting to try this with
> different CONFIG_HZ too e.g. you could start with 100 (I guess, you
> tested very similar thing in 2.6.23-rc2 with 1000(?) already).
> 
> Jean-Baptiste: you can skip/break testing of this 'experimental'

ok

I was still testing on -rc2:
Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Wed, 8 Aug 2007 13:00:37 +0200

For me after 1day 20hours, the network is still up, with more than 1To 
of network traffic. HZ was 1000, i restart with HZ=100.

Jb
