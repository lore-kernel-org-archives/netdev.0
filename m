From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/6 resend] pkt_sched: sch_htb: Break all
 htb_do_events() after 2 jiffies
Date: Mon, 12 Jan 2009 21:54:59 -0800 (PST)
Message-ID: <20090112.215459.51832663.davem@davemloft.net>
References: <20081209144534.GC15353@ff.dom.local>
	<493E8709.5070601@trash.net>
	<20090112101745.GB5781@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42929
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754829AbZAMFy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:54:58 -0500
In-Reply-To: <20090112101745.GB5781@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 12 Jan 2009 10:17:46 +0000

> pkt_sched: sch_htb: Break all htb_do_events() after 2 jiffies
> 
> Currently htb_do_events() breaks events recounting for a level after 2
> jiffies, but there is no reason to repeat this for next levels and
> increase delays even more (with softirqs disabled). htb_dequeue_tree()
> can add to this too, btw. In such a case q->now time is invalid anyway.
> 
> Thanks to Patrick McHardy for spotting an error around earlier version
> of this patch.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Also applied, thanks Jarek.
