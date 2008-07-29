From: David Miller <davem@davemloft.net>
Subject: Re: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Tue, 29 Jul 2008 13:47:06 -0700 (PDT)
Message-ID: <20080729.134706.249036102.davem@davemloft.net>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	<20080729215315.5a505fe7.komurojun-mbn@nifty.com>
	<20080729065859.2bcc65ed@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: komurojun-mbn@nifty.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752479AbYG2UrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 16:47:10 -0400
In-Reply-To: <20080729065859.2bcc65ed@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 29 Jul 2008 06:58:59 -0700

> On Tue, 29 Jul 2008 21:53:15 +0900
> Komuro <komurojun-mbn@nifty.com> wrote:
> 
> > Hi,
> > 
> > Please try to comment out the "WARN_ON_ONCE"
> > at net/sched/sched_generic.c.
> > 
> 
> "I have a hardware failure so I'll comment out the message that says
> so, and then I won't have a failure". Yeah that'll work well.

Yes, this is indeed a recidulious suggestion, to hide the problem
instead of trying to figure out what it might actually be.

Komuro has a serious problem accepting the fact that this condition is
in fact an abnormal error should should be logged, and he keeps
pushing to get this WARN_ON() removed over and over again.

I'm just ignoring him at this point.
