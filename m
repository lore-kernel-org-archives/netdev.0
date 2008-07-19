From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: missing lock initialization
Date: Fri, 18 Jul 2008 17:49:48 -0700 (PDT)
Message-ID: <20080718.174948.93120743.davem@davemloft.net>
References: <20080718161048.678a9629@extreme>
	<20080718163836.60f5a021@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751045AbYGSAts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:49:48 -0400
In-Reply-To: <20080718163836.60f5a021@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Jul 2008 16:38:36 -0700

> Looks like the xmit_lock is not being initialized in net-next
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I guess you can't find the call in __netdev_init_queue_locks_one().

With your patch we'll now be initializing it twice.
