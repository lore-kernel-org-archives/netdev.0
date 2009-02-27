From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 03:16:20 -0800 (PST)
Message-ID: <20090227.031620.155361122.davem@davemloft.net>
References: <20090227101634.GD4156@ff.dom.local>
	<20090227.024613.141114390.davem@davemloft.net>
	<20090227110137.GF4156@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752368AbZB0LQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 06:16:39 -0500
In-Reply-To: <20090227110137.GF4156@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Feb 2009 11:01:37 +0000

> On Fri, Feb 27, 2009 at 02:46:13AM -0800, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Fri, 27 Feb 2009 10:16:34 +0000
> > 
> > > pkt_sched: sch_drr: Fix oops in drr_change_class.
> > > 
> > > drr_change_class lacks a check for NULL of tca[TCA_OPTIONS], so oops
> > > is possible.
> > > 
> > > Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> > > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > 
> > Applied and queued up for -stable, thanks Jarek!
> 
> Hmm... if 2.6.29-rcX means -stable...

This bug doesn't exist in earlier releases like 2.6.28 and 2.6.27?
