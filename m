From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bridge: Fix build error when
 IGMP_SNOOPING is not enabled
Date: Mon, 01 Mar 2010 18:14:32 -0800 (PST)
Message-ID: <20100301.181432.04478860.davem@davemloft.net>
References: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
	<20100302004626.GA28274@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215Ab0CBCOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 21:14:14 -0500
In-Reply-To: <20100302004626.GA28274@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 2 Mar 2010 08:46:26 +0800

> On Mon, Mar 01, 2010 at 11:53:04AM -0800, Sridhar Samudrala wrote:
>> Fix the following build error when IGMP_SNOOPING is not enabled.
>> In file included from net/bridge/br.c:24:
>> net/bridge/br_private.h: In function 'br_multicast_is_router':
>> net/bridge/br_private.h:361: error: 'struct net_bridge' has no member named 'multicast_router'
>> net/bridge/br_private.h:362: error: 'struct net_bridge' has no member named 'multicast_router'
>> net/bridge/br_private.h:363: error: 'struct net_bridge' has no member named 'multicast_router_timer'
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Thanks for the fix.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I'd originally left the struct data outside ifdefs and then added
> the ifdefs without testing.

Thanks everyone, I'll apply this.
