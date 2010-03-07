From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Sun, 07 Mar 2010 15:31:27 -0800 (PST)
Message-ID: <20100307.153127.98692943.davem@davemloft.net>
References: <20100306050656.GA6812@linux.vnet.ibm.com>
	<20100306065655.GA14326@gondor.apana.org.au>
	<20100306070335.GA14470@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41629
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931Ab0CGXbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:31:08 -0500
In-Reply-To: <20100306070335.GA14470@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 6 Mar 2010 15:03:35 +0800

> On Sat, Mar 06, 2010 at 02:56:55PM +0800, Herbert Xu wrote:
>>
>> > In contrast, rcu_barrier_bh() is guaranteed not to return until all
>> > pending RCU-bh callbacks have executed.
>> 
>> You're absolutely right.  I'll send a patch to fix this.
> 
> bridge: Fix RCU race in br_multicast_stop
> 
> Thanks to Paul McKenny for pointing out that it is incorrect to use 
> synchronize_rcu_bh to ensure that pending callbacks have completed.
> Instead we should use rcu_barrier_bh.
> 
> Reported-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
