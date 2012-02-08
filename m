From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] FEC: Rename dev to ndev, fix compile error
Date: Tue, 07 Feb 2012 19:04:30 -0500 (EST)
Message-ID: <20120207.190430.1219273346186860486.davem@davemloft.net>
References: <1328654548-28396-1-git-send-email-marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infreadead.org, netdev@vger.kernel.org,
	netdev@pradeepdalvi.com
To: marek.vasut@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2BHAEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 19:04:37 -0500
In-Reply-To: <1328654548-28396-1-git-send-email-marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marek.vasut@gmail.com>
Date: Tue,  7 Feb 2012 23:42:28 +0100

> The following commit introduced a typo, this commit fixes it.
> 
> commit 21a4e46995fa1a76281ac0281ff837f706231a37
> Author: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> Date:   Sun Feb 5 02:50:10 2012 +0000
> 
>     netdev: ethernet dev_alloc_skb to netdev_alloc_skb
> 
>     Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>       - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Marek Vasut <marek.vasut@gmail.com>

This is already fixed in the net-next tree.
