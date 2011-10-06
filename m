From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Thu, 06 Oct 2011 15:28:14 -0400 (EDT)
Message-ID: <20111006.152814.1080448946858474074.davem@davemloft.net>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.191082289@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab1JFT2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:28:17 -0400
In-Reply-To: <20111004041509.191082289@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 03 Oct 2011 21:14:45 -0700

> This resolves a regression seen by some users of bridging.
> Some users use the bridge like a dummy device. 
> They expect to be able to put an IPv6 address on the device
> with no ports attached. Although there are better ways of doing
> this, there is no reason to not allow it.
> 
> Note: the bridge still will reflect the state of ports in the
> bridge if there are any added.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to 'net' and queued up for -stable.
