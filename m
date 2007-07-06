From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Fri, 6 Jul 2007 08:14:21 +0200
Message-ID: <20070706061420.GA1846@ff.dom.local>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org> <1183642800.3789.11.camel@ranko-fc2.spidernet.net> <20070705142135.GG4759@ff.dom.local> <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:42144 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754843AbXGFGFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 02:05:50 -0400
Content-Disposition: inline
In-Reply-To: <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 06:59:25PM +0300, Ranko Zivojnovic wrote:
> On Thu, 2007-07-05 at 17:34 +0300, Ranko Zivojnovic wrote:
> > Anyhow - I am currently running 2.6.22-rc6-mm1 + sch_htb patch and
> > running a test script that always managed to reproduce the problem
> > within half hour - so far it looks good, but I will leave it hammering
> > until tomorrow and will let you know.
> > 
> 
> Ahm...it managed to get stuck:
> 
> Relevant piece of the process table ('tc' stays stuck):
>  9608 pts/0    S+     0:00 /bin/bash ./tc-crash.sh
>  9609 pts/0    D+     0:00 tc qdisc del dev lo root
> 
> There was no soft lockup kernel warning however sysreq 'w' & 'q' dump
> the following:
> 
> ---cut---

I have to admit you are really good at this testing!

Especially after this first htb bug I was almost stunned,
how long such repeatable and not very hidden bug can
live in one of the most popular networking modules...

This new lockup bug you have just found needs some time
to figure out. BTW, I wonder if you had lockdep on
(CONFIG_PROVE_LOCKING or CONFIG_LOCK_ALLOC)?

Thanks & regards,
Jarek P.

PS: I hope you don't mind I forward this to netdev.
