From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 19:48:56 -0700 (PDT)
Message-ID: <20080720.194856.92564555.davem@davemloft.net>
References: <20080721010952.GA4822@martell.zuzino.mipt.ru>
	<20080720.181440.122144107.davem@davemloft.net>
	<20080721024056.GA4800@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759894AbYGUCs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 22:48:57 -0400
In-Reply-To: <20080721024056.GA4800@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 21 Jul 2008 06:40:56 +0400

> OK, the problem is really this buglet:
> 
> 	BUG_ON(q == &noop_qdisc);
> 	__netif_schedule
> 	netif_tx_wake_queue
> 	netif_wake_queue
> 	atl1_check_link
> 	atl1_up		or	atlx_link_chg_task
> 				run_workqueue

Thanks for the backtrace I'll work on fixing this.
