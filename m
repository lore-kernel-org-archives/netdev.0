From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix TX buffer byte-swapping
Date: Tue, 15 Dec 2015 00:25:26 -0500 (EST)
Message-ID: <20151215.002526.199770124958086952.davem@davemloft.net>
References: <4052048.4A561jYI0l@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbbLOFZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 00:25:31 -0500
In-Reply-To: <4052048.4A561jYI0l@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Dec 2015 21:27:04 +0300

> For the little-endian SH771x kernels the driver has to byte-swap the RX/TX
> buffers,  however yet unset physcial address from the TX descriptor is used
> to call sh_eth_soft_swap(). Use 'skb->data' instead...
> 
> Fixes: 31fcb99d9958 ("net: sh_eth: remove __flush_purge_region")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
