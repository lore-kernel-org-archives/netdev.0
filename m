From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Mon, 9 Jul 2007 10:25:23 +0200
Message-ID: <20070709082522.GB1851@ff.dom.local>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org> <1183642800.3789.11.camel@ranko-fc2.spidernet.net> <20070705142135.GG4759@ff.dom.local> <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net> <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local> <20070706064523.GA2144@ff.dom.local> <20070706124711.GA3453@ff.dom.local> <1183727778.6389.6.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54515 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751171AbXGIIQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 04:16:45 -0400
Content-Disposition: inline
In-Reply-To: <1183727778.6389.6.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 04:16:18PM +0300, Ranko Zivojnovic wrote:
> On Fri, 2007-07-06 at 14:47 +0200, Jarek Poplawski wrote:
> > On Fri, Jul 06, 2007 at 08:45:23AM +0200, Jarek Poplawski wrote:
> > > On Fri, Jul 06, 2007 at 09:08:43AM +0300, Ranko Zivojnovic wrote:
> > ...
> > > > In order to get that parameter out of the way - I will make the same
> > > > test on a real machine.
> > 
> > BTW, maybe it would be better to try with something more stable than -mm.
> 
> That would be the next thing I was to try. Suggestion?

Of course, -mm needs testing too, and it's probably easier
to find bugs here, but it's hard to check fixes: you never
know if the new bugs are caused by the fix or the fix only
uncovered them. So, last stable or -rc versions (at least
with higher numbers) should make things faster. 

I've looked a bit on this first log, and it's very strange,
especially stats of cpu#0. Maybe it's really about vmware
or maybe there is something more, but it doesn't seem this
stats_lock deadlock could've done all this mess. Anyway, it
would be interesting to repeat such test with -mm after
checking e.g. with 2.6.22.

Thanks,
Jarek P.

PS: Sorry for late responding.
