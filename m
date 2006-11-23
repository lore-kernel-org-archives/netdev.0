From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 10:01:13 +0100
Message-ID: <20061123090113.GB1586@ff.dom.local>
References: <20061123083909.GA1586@ff.dom.local> <45655F54.2020501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.go2.pl ([193.17.41.41]:31152 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932652AbWKWIys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 03:54:48 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45655F54.2020501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 09:44:04AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >>+static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
> >>+{
> >>+	struct htb_class *cl = (struct htb_class *)arg;
> >>+
> >>+	if (cl->un.leaf.q->q.qlen == 0)
> > 
> > 
> > Probably "if (cl->prio_activity)" is needed here.
> 
> 
> No, the function is only called for active leaf classes, which
> always have prio_activity != 0.

So this was unnecessary in htb_graft? You should know better...

Jarek P. 
