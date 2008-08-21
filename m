From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 06:33:06 -0700 (PDT)
Message-ID: <32413.7552.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756852AbYHUNdX@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> > Please advise me on how you would like me to handle 2.6.27 kernels.
> > If I use your patch on 2.6.27-rc3, the message scroll off the 80x25 
> > screen before I can see them... 
> 
> Couldn't you play with CONFIG_BOOT_PRINTK_DELAY?

Thanks for this!  I am not a developer, so I am not familiar with all
of the little tweaks available in the kernel configs -- I've probably
seen this dozens of times, but ignored it because I wasn't debugging.

Now that I _am_ debugging, I wish I had paid more attention.

When I tried it, my kernel hung much earlier in the boot process.  The
help text for CONFIG_BOOT_PRINTK_DELAY even mentions that this can be
a problems on SMP systems, and that is exactly what I have.

Bummer.


Thanks though,
Dave W.
