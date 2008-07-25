From: David Miller <davem@davemloft.net>
Subject: Re: [lockdep warning] AOE / networking: aoenet_xmit:
 noop_qdisc.q.lock, INFO: inconsistent lock state at 0000000000000370
Date: Fri, 25 Jul 2008 01:23:21 -0700 (PDT)
Message-ID: <20080725.012321.19139111.davem@davemloft.net>
References: <20080725062009.GA6476@elte.hu>
	<20080724.232521.193699299.davem@davemloft.net>
	<20080725072624.GA21824@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecashin@coraid.com, axboe@suse.de, mike.miller@hp.com,
	a.p.zijlstra@chello.nl, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752301AbYGYIXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 04:23:22 -0400
In-Reply-To: <20080725072624.GA21824@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 25 Jul 2008 09:26:24 +0200

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Fri, 25 Jul 2008 08:20:09 +0200
> > 
> > > not sure whether it got reported already, but -tip testing triggered 
> > > this new ATA over Ethernet lockdep warning on latest -git:
> > 
> > Thanks for the report, does this fix it?
> 
> i've tested it and the warning went away - thanks David!
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks for testing.
