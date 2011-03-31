From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] fib: add __rcu annotations
Date: Thu, 31 Mar 2011 01:51:45 -0700 (PDT)
Message-ID: <20110331.015145.226789095.davem@davemloft.net>
References: <1301561072.3169.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754327Ab1CaIwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 04:52:22 -0400
In-Reply-To: <1301561072.3169.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 31 Mar 2011 10:44:32 +0200

> Add __rcu annotations and lockdep checks.
> 
> Add const qualifiers
> 
> node_parent() and node_parent_rcu() can use
> rcu_dereference_index_check()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
