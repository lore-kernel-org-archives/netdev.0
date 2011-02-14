From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: fix rcu lock imbalance in
 fib_select_default()
Date: Mon, 14 Feb 2011 11:23:45 -0800 (PST)
Message-ID: <20110214.112345.71108636.davem@davemloft.net>
References: <1297692124.2996.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752754Ab1BNTXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:23:09 -0500
In-Reply-To: <1297692124.2996.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Feb 2011 15:02:04 +0100

> Commit 0c838ff1ade7 (ipv4: Consolidate all default route selection
> implementations.) forgot to remove one rcu_read_unlock() from
> fib_select_default().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
