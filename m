From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: [NETPOLL] netconsole: fix soft lockup when
 removing module
Date: Tue, 03 Jul 2007 23:47:18 -0700 (PDT)
Message-ID: <20070703.234718.61506862.davem@davemloft.net>
References: <20070701173558.GA207@tv-sign.ru>
	<20070702075226.GB1639@ff.dom.local>
	<20070704064159.GA2057@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oleg@tv-sign.ru, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33446
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753262AbXGDGq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 02:46:59 -0400
In-Reply-To: <20070704064159.GA2057@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Wed, 4 Jul 2007 08:41:59 +0200

> On Mon, Jul 02, 2007 at 09:52:26AM +0200, Jarek Poplawski wrote:
> > 
> > From my recent patch:
> > 
> > > >    #1
> > > >    Until kernel ver. 2.6.21 (including) cancel_rearming_delayed_work()
> > > >    required a work function should always (unconditionally) rearm with
> > > >    delay > 0 - otherwise it would endlessly loop. This patch replaces
> > > >    this function with cancel_delayed_work(). Later kernel versions don't
> > > >    require this, so here it's only for uniformity.
> > 
> > But Oleg Nesterov <oleg@tv-sign.ru> found:
> > 
> > > But 2.6.22 doesn't need this change, why it was merged?
> > > 
> > > In fact, I suspect this change adds a race,
> > ...
> > 
> > His description was right (thanks), so this patch reverts #1.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Oleg,
> 
> I think maybe you could ack these 2 netconsole patches...
> They were done on your request but it looks like Andrew
> is waiting on something...

I plan to apply this patch, don't worry about it :)
