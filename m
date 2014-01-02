From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] alx: add alx_get_stats operation
Date: Wed, 01 Jan 2014 22:27:02 -0500 (EST)
Message-ID: <20140101.222702.1562824655053158808.davem@davemloft.net>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	<1388619628-3373-5-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbaABD1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:27:03 -0500
In-Reply-To: <1388619628-3373-5-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu,  2 Jan 2014 00:40:27 +0100

> +	spin_lock(&alx->stats_lock);
> +
> +	__alx_update_hw_stats(&alx->hw);

Please use something like the linux/u64_stats_sync.h stuff rather
than spin locking.

Thank you.
