From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pppoe: RCU locking in get_item_by_addr()
Date: Sun, 01 Nov 2009 23:57:34 -0800 (PST)
Message-ID: <20091101.235734.211813660.davem@davemloft.net>
References: <4AEE735A.4020601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753989AbZKBH5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:57:09 -0500
In-Reply-To: <4AEE735A.4020601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 06:51:22 +0100

> 
> Note : this patch depends on dev_get_by_name_rcu(), not yet comitted.

Yep, I just tossed that one ine.

> [PATCH net-next-2.6] pppoe: RCU locking in get_item_by_addr()
> 
> Use dev_get_by_name_rcu() instead of dev_get_by_name(),
> to avoid touching device refcount in hotpath.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

And now this one too, applied, thanks!
