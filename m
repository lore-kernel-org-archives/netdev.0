From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] vxge: fix 64 bit access on 32 bit
 platforms
Date: Tue, 21 Jun 2011 15:56:03 -0700 (PDT)
Message-ID: <20110621.155603.512721164385831874.davem@davemloft.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620203602.653878704@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab1FUW4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 18:56:05 -0400
In-Reply-To: <20110620203602.653878704@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 20 Jun 2011 13:35:07 -0700

> Need to add stat_sync wrapper around 64 bit statistic values.
> Fix wraparound bug in lockup detector where it is unsafely comparing
> 64 bit value that is not atomic. Since only care about detecting activity
> just looking at current low order bits will work.
> 
> Remove unused entries in old vxge_sw_stats structure.
> Change the error counters to unsigned long since they won't grow so large
> as to have to be 64 bits.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
