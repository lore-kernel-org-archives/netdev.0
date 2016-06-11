From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 -next] sched: remove NET_XMIT_POLICED
Date: Sun, 12 Jun 2016 00:57:06 +0200
Message-ID: <20160611225706.GA16798@breakpoint.cc>
References: <1465641964-12342-1-git-send-email-fw@strlen.de>
 <20160611.155407.1424553523659683009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38144 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752111AbcFKW5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:57:12 -0400
Content-Disposition: inline
In-Reply-To: <20160611.155407.1424553523659683009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 11 Jun 2016 12:46:04 +0200
> 
> > sch_atm returns this when TC_ACT_SHOT classification occurs.
> > 
> > But all other schedulers that use tc_classify
> > (htb, hfsc, drr, fq_codel ...) return NET_XMIT_SUCCESS | __BYPASS
> > in this case so just do that in atm.
> 
> Yes, but it's been like this for two decades.
> 
> One of the points of my reply to the previous version of this
> patch is that indeed it is explicitly returned, intentionally.

But nothing evaluates it?

Only exception is pktgen which treats it line _CN and _DROP...

[ But I dont mind if you'd rather leave it alone, I just find it
  silly we have a NET_XMIT_ that has no clear meaning or use ]
