From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Thu, 01 Dec 2011 19:25:17 -0500 (EST)
Message-ID: <20111201.192517.1865830932968025090.davem@davemloft.net>
References: <1322684749.2602.3.camel@edumazet-laptop>
	<20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
	<1322773594.2750.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, tgraf@infradead.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551Ab1LBA0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 19:26:31 -0500
In-Reply-To: <1322773594.2750.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 22:06:34 +0100

> [PATCH] sch_red: fix red_change()
> 
> Now RED is classful, we must check q->qdisc->q.qlen, and if queue is empty,
> we start an idle period, not end it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric.
