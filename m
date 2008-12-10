From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
 htb_dequeue()
Date: Wed, 10 Dec 2008 01:14:31 -0800 (PST)
Message-ID: <20081210.011431.203551043.davem@davemloft.net>
References: <20081209144534.GC15353@ff.dom.local>
	<20081209.223545.196224587.davem@davemloft.net>
	<20081210091126.GA4707@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751531AbYLJJOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:14:30 -0500
In-Reply-To: <20081210091126.GA4707@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 10 Dec 2008 09:11:26 +0000

> On Tue, Dec 09, 2008 at 10:35:45PM -0800, David Miller wrote:
> > So once you work this stuff out please resubmit the rest.
> 
> Of course, I can resubmit 1 and 4 if you think it's really needed.

Please do, there were dependencies.  In fact patch 2 changes
the very change you made in patch 1.

I understand it's logical steps, but you could just do 1 and
2 in the same patch and it'd be OK.
