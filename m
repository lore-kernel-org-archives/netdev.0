From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 12:31:51 -0700 (PDT)
Message-ID: <20070316.123151.88702898.davem@davemloft.net>
References: <45FA6682.10303@trash.net>
	<20070316124124.GK521@postel.suug.ch>
	<45FA916C.2080501@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, devik@cdi.cz, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933083AbXCPTbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 15:31:52 -0400
In-Reply-To: <45FA916C.2080501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 16 Mar 2007 13:45:32 +0100

> Thomas Graf wrote:
> > * Patrick McHardy <kaber@trash.net> 2007-03-16 10:42
> > 
> >>David Miller wrote:
> >>
> >>>It would be nice to figure out why CBQ isn't working for
> >>>you, I know at least some folks have used it successfully
> >>>at some point.
> >>
> >>Probably my own incompetence, I'll see if I can find some
> >>scripts that are known to work.
> > 
> > 
> > I'll complain if it stops working, I'm still using CBQ to
> > keep rsync and other bulk flows from interfering with ssh.
> > HTB just doesn't have the same homy touch :-)
> 
> :)
> 
> I managed to find a working script in the meantime and discovered
> a bug in my changes, with this patch on top it seems to works fine.

Thank a lot Patrick, patch applied.
