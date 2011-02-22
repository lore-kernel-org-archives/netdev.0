From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add __rcu annotations to sk_wq and wq
Date: Tue, 22 Feb 2011 10:19:34 -0800 (PST)
Message-ID: <20110222.101934.115942250.davem@davemloft.net>
References: <1298035596.6201.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754989Ab1BVSS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 13:18:57 -0500
In-Reply-To: <1298035596.6201.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Feb 2011 14:26:36 +0100

> Add proper RCU annotations/verbs to sk_wq and wq members
> 
> Fix __sctp_write_space() sk_sleep() abuse (and sock->wq access)
> 
> Fix sunrpc sk_sleep() abuse too
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
