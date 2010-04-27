From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: fix a lockdep rcu warning in
 __sk_dst_set()
Date: Tue, 27 Apr 2010 12:42:11 -0700 (PDT)
Message-ID: <20100427.124211.214227480.davem@davemloft.net>
References: <1272350443.4861.9.camel@edumazet-laptop>
	<20100427161716.GB2424@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754900Ab0D0TmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:42:06 -0400
In-Reply-To: <20100427161716.GB2424@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 27 Apr 2010 09:17:16 -0700

> On Tue, Apr 27, 2010 at 08:40:43AM +0200, Eric Dumazet wrote:
>> __sk_dst_set() might be called while no state can be integrated in a
>> rcu_dereference_check() condition.
>> 
>> So use rcu_dereference_raw() to shutup lockdep warnings (if
>> CONFIG_PROVE_RCU is set)
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've applied this to net-next-2.6, thanks!
