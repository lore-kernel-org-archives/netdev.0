From: David Miller <davem@davemloft.net>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 13:27:50 -0700 (PDT)
Message-ID: <20080813.132750.16161628.davem@davemloft.net>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbYHMU1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 16:27:48 -0400
In-Reply-To: <48A30834.4090802@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 13 Aug 2008 12:13:40 -0400

> David Miller wrote:
> > From: Andrew Gallatin <gallatin@myri.com>
> > Date: Tue, 12 Aug 2008 20:56:23 -0400
> > 
> >>      pkt_sched: Schedule qdiscs instead of netdev_queue.
> > 
> > While I'm waiting for your beforehand profile data,
> > here is a stab in the dark patch which might fix
> > the problem.
> > 
> > Robert, this could explain some of the things in the
> > multiqueue testing profile you sent me a week or so
> > ago.
> > 
> > Let me know how well it works:
> 
> Excellent!  This completely fixes the increased CPU
> utilization I observed on both 10GbE and 1GbE interfaces,
> and CPU utilization is now reduced back to 2.6.26 levels.
> 
> Oprofile now is nearly identical to what it was prior to
> 37437bb2e1ae8af470dfcd5b4ff454110894ccaf:

Thanks for testing and providing those profiles.

I'll get this fix to Linus soon.
