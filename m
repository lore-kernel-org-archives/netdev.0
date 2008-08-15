From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- question about NMI watchdog
Date: Fri, 15 Aug 2008 05:49:17 -0700 (PDT)
Message-ID: <445817.22956.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82101.mail.mud.yahoo.com ([209.191.84.214]:27753 "HELO
	web82101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753557AbYHOMtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 08:49:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > I found something very interesting about the commit that first causes 
> > the lockup (3def3d6d...), and the very next commit (1e934dda...) -- if 
> > I checkout 1e94... and try to revert the changes made in 3def..., the 
> > kernel freezes in spite of the revert.
> > 
> > Because of this, I would conclude that your patch for 2.6.27-rc3 was 
> > doomed before you began, and we should look more carefully at the 
> > commits from February instead of trying to revert at the 2.6.27 HEAD.
> 
> i'm still wondering whether we could try to figure out something about 
> the nature of the hard lockup itself.
> 
> Have you tried to activate the NMI watchdog? It _usually_ works fine if 
> you use a boot option along the lines of:
> 
>    "lapic nmi_watchdog=2 idle=poll"

I have to go to work for a few hours right now, but will try this out when
I get home.  (Actually, I'm late for work as I type this... but I have my
priorities straight!  ;)

Quick question:  a quick browse of 'Documentation/nmi_watchdog.txt' suggests
that I should use "nmi_watchdog=1", since I have SMP (CPU = Athlon 64 X2,
with CONFIG_SMP=y).  Should I follow your suggestion later, or follow the
recommendation of the 'nmi_watchdog.txt' doc?


Much thanks,
Dave W.
