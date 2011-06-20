From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] myricom: remove stats_lock
Date: Mon, 20 Jun 2011 13:02:54 -0700 (PDT)
Message-ID: <20110620.130254.420359139850129723.davem@davemloft.net>
References: <1308550066.3539.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com, brice@myri.com,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773Ab1FTUC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:02:59 -0400
In-Reply-To: <1308550066.3539.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 08:07:46 +0200

> stats_lock is non useless, lets remove it.
> 
> Also, ndo_get_stats64() doesnt have to clear the stats, caller takes
> care of this.
> 
> Note: folding 32bit fields in 64bit one is problematic when one of 32bit
> values wraps : SNMP reader will see a ~2^32 back change in a 64bit
> value. A future patch should fix this.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
