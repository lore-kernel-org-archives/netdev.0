From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: do not use zero refcnt for
 freed entries
Date: Tue, 15 Jun 2010 21:47:54 -0700 (PDT)
Message-ID: <20100615.214754.42801686.davem@davemloft.net>
References: <1276626194.2541.186.camel@edumazet-laptop>
	<20100615.142506.02275206.davem@davemloft.net>
	<1276656324.19249.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49092
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751873Ab0FPErn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 00:47:43 -0400
In-Reply-To: <1276656324.19249.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Jun 2010 04:45:24 +0200

> [PATCH net-next-2.6] inetpeer: do not use zero refcnt for freed entries
> 
> Followup of commit aa1039e73cc2 (inetpeer: RCU conversion)
> 
> Unused inet_peer entries have a null refcnt.
> 
> Using atomic_inc_not_zero() in rcu lookups is not going to work for
> them, and slow path is taken.
> 
> Fix this using -1 marker instead of 0 for deleted entries.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
