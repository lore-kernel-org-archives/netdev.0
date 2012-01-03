From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_qfq: accurate wsum handling
Date: Tue, 03 Jan 2012 13:02:28 -0500 (EST)
Message-ID: <20120103.130228.1500037536495574204.davem@davemloft.net>
References: <1325540870.2874.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283Ab2ACSCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:02:31 -0500
In-Reply-To: <1325540870.2874.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jan 2012 22:47:50 +0100

> We can underestimate q->wsum in case of "tc class replace ... qfq"
> and/or qdisc_create_dflt() error.
> 
> wsum is not really used in fast path, only at qfq qdisc/class setup,
> to catch user error.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
