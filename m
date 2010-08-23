From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 20:18:33 -0300
Message-ID: <20100823231833.GL2973@ghostprotocols.net>
References: <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com> <20100823220129.GB2745@nuttenaction> <AANLkTinb_tjcz=AF1-2i7MK=Bgm7aEtozjb3Ds0swi8q@mail.gmail.com> <20100823.152330.184822588.davem@davemloft.net> <20100823231726.GK2973@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chris.snook@gmail.com, hagen@jauu.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096Ab0HWXSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 19:18:48 -0400
Content-Disposition: inline
In-Reply-To: <20100823231726.GK2973@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Aug 23, 2010 at 08:17:26PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Aug 23, 2010 at 03:23:30PM -0700, David Miller escreveu:
> > From: Chris Snook <chris.snook@gmail.com>
> > Date: Mon, 23 Aug 2010 18:19:45 -0400
> > 
> > > Just because we've allowed stupid TCP sysctls in the past does not
> > > mean we should continue to do so now.  We recently made delayed ack a
> > > per-route tunable, so consistency would suggest we do the same here.
> > > Per-route tunables are more flexible, and as with the delayed ack
> > > patch, there are use cases where that granularity gives a clear
> > > advantage over a sysctl.  For example, you may want to disable quick
> > > ack on a high-MTU path and enable it on a low-MTU path.
> > > 
> > > If you need a hint for how to implement the per-route tunable, look
> > > for the delayed ack patch from early 2009.
> > 
> > I completely agree with Chris that this should be a per-route rather
> > than a global sysctl tunable.
> 
> My first impression was not so strong as to participate, if every
> tunable gets a knob, well, we'd be flying concordes in no time.

Gack, s/tunable/heuristic/g
 
> But even with such reaction, I thought that if a tunable would be
> interesting to have would be a setsockopt one, that knowledgeable,
> performance/latency hungry actors would jump into as if they were really
> hungry.
> 
> And yes, that knob I worked on got lost along the way, I guess I have to
> think again about it and submit.
> 
> - Arnaldo
