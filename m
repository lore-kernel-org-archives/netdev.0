From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 16:25:51 -0700 (PDT)
Message-ID: <20080328.162551.252642805.davem@davemloft.net>
References: <20080328105629.GG1011@elte.hu>
	<20080328110621.GA23342@gondor.apana.org.au>
	<20080328112928.GA23547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, Matheos.Worku@Sun.COM, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35521
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754404AbYC1XZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:25:54 -0400
In-Reply-To: <20080328112928.GA23547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Mar 2008 19:29:28 +0800

> [NET]: Add preemption point in qdisc_run
> 
> The qdisc_run loop is currently unbounded and runs entirely
> in a softirq.  This is bad as it may create an unbounded softirq
> run.
> 
> This patch fixes this by calling need_resched and breaking out
> if necessary.
> 
> It also adds a break out if the jiffies value changes since that
> would indicate we've been transmitting for too long which starves
> other softirqs.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and I'll queue this up for -stable, thanks!
