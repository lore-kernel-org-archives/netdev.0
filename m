From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: add a truesize parameter to skb_add_rx_frag()
Date: Sun, 25 Mar 2012 13:30:17 -0400 (EDT)
Message-ID: <20120325.133017.755244992502310658.davem@davemloft.net>
References: <1332508626.4858.20.camel@edumazet-laptop>
	<1332583173.3487.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wey-yi.w.guy@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978Ab2CYRaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 13:30:21 -0400
In-Reply-To: <1332583173.3487.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 24 Mar 2012 02:59:33 -0700

> skb_add_rx_frag() API is misleading.
> 
> Network skbs built with this helper can use uncharged kernel memory and
> eventually stress/crash machine in OOM.
> 
> Add a 'truesize' parameter and then fix drivers in followup patches.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
