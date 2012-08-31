From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix documentation of skb_needs_linearize().
Date: Fri, 31 Aug 2012 16:24:20 -0400 (EDT)
Message-ID: <20120831.162420.659402539100971755.davem@davemloft.net>
References: <1346146764-23516-1-git-send-email-rosenr@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rosenr@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859Ab2HaUYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:24:22 -0400
In-Reply-To: <1346146764-23516-1-git-send-email-rosenr@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rosenr@marvell.com>
Date: Tue, 28 Aug 2012 12:39:24 +0300

> skb_needs_linearize() does not check highmem DMA as it does not call
> illegal_highdma() anymore, so there is no need to mention highmem DMA here.
> 
> (Indeed, ~NETIF_F_SG flag, which is checked in skb_needs_linearize(), can
> be set when illegal_highdma() returns true, and we are assured that
> illegal_highdma() is invoked prior to skb_needs_linearize() as
> skb_needs_linearize() is a static method called only once.
> But ~NETIF_F_SG can be set not only there in this same invocation path.
> It can also be set when can_checksum_protocol() returns false).
> 
> see commit 02932ce9e2c136e6fab2571c8e0dd69ae8ec9853,
> Convert skb_need_linearize() to use precomputed features.
> Signed-off-by: Rami Rosen <rosenr@marvell.com>

Applied to net-next, thanks Rami.
