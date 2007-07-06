From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Fri, 6 Jul 2007 08:45:23 +0200
Message-ID: <20070706064523.GA2144@ff.dom.local>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org> <1183642800.3789.11.camel@ranko-fc2.spidernet.net> <20070705142135.GG4759@ff.dom.local> <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net> <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:41420 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757334AbXGFGgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 02:36:53 -0400
Content-Disposition: inline
In-Reply-To: <20070706062629.GC1846@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 09:08:43AM +0300, Ranko Zivojnovic wrote:
> On Thu, 2007-07-05 at 18:59 +0300, Ranko Zivojnovic wrote:
> > On Thu, 2007-07-05 at 17:34 +0300, Ranko Zivojnovic wrote:
> > > Anyhow - I am currently running 2.6.22-rc6-mm1 + sch_htb patch and
> > > running a test script that always managed to reproduce the problem
> > > within half hour - so far it looks good, but I will leave it hammering
> > > until tomorrow and will let you know.
> > > 
> > 
> > Ahm...it managed to get stuck:
> > 
> > Relevant piece of the process table ('tc' stays stuck):
> >  9608 pts/0    S+     0:00 /bin/bash ./tc-crash.sh
> >  9609 pts/0    D+     0:00 tc qdisc del dev lo root
> > 
> 
> Something really weird happened here...
> 
> I've left it the way it was (stuck) over night and this morning the
> process was terminated.
> 
> It looks like some timer was out of whack.
> 
> I'm not sure if it is possibly relevant - but the test I performed was
> done in VMWare.

Yes, this could be relevant, so it's good to know.

> 
> In order to get that parameter out of the way - I will make the same
> test on a real machine.

Fine! But, unles you have something to hide, try to reply
on these messages which went through netdev, or cc netdev
at least, because maybe more people would be interested
or even could help to solve this faster.

Cheers,
Jarek P.
