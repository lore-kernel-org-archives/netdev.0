From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 14:24:15 +0200
Message-ID: <20090616122415.GA16630@elte.hu>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60973 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbZFPMYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 08:24:21 -0400
Content-Disposition: inline
In-Reply-To: <20090616105304.GA3579@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Tue, 16 Jun 2009 11:15:38 +0200
> > 
> > > 
> > > hm, FYI, these bits caused widespread scheduling-while-atomic 
> > > problems on most of my test-systems:
> > > 
> > > BUG: sleeping function called from invalid context at net/core/sock.c:1851
> > > in_atomic(): 1, irqs_disabled(): 0, pid: 544, name: rcu_torture_rea
> > > 1 lock held by rcu_torture_rea/544:
> > >  #0:  (&sk->sk_timer){......}, at: [<ffffffff81060560>] run_timer_softirq+0x120/0x2e0
> > > Pid: 544, comm: rcu_torture_rea Tainted: G        W  2.6.30-tip #54067
> > > Call Trace:
> > >  [<ffffffff810820c3>] ? __debug_show_held_locks+0x13/0x30
> > >  [<ffffffff810489e6>] __might_sleep+0xf6/0x120
> > >  [<ffffffff81b3921d>] lock_sock_nested+0x3d/0x120
> > >  [<ffffffff81c1a7d2>] x25_destroy_socket+0x22/0x180
> > 
> > Please give this patch a try.
> 
> Started testing it - thanks David!

With several dozen test-cycles (and [a]x25 reactivated) it looks 
good and stable so far.

Thanks,

	Ingo
