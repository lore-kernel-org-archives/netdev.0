From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_qfq: fix overflow in qfq_update_start()
Date: Tue, 03 Jan 2012 12:59:07 -0500 (EST)
Message-ID: <20120103.125907.270899701719279707.davem@davemloft.net>
References: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283Ab2ACR7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:59:16 -0500
In-Reply-To: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jan 2012 16:47:57 +0100

> grp->slot_shift is between 22 and 41, so using 32bit wide variables is
> probably a typo.
> 
> This could explain QFQ hangs Dave reported to me, after 2^23 packets ?
> 
> (23 = 64 - 41)
> 
> Reported-by: Dave Taht <dave.taht@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Dave Taht <dave.taht@gmail.com>

Applied, thanks Eric.
