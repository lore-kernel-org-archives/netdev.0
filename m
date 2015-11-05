From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: merge sh_eth_free_dma_buffer() into
 sh_eth_ring_free()
Date: Wed, 04 Nov 2015 20:59:39 -0500 (EST)
Message-ID: <20151104.205939.1680085474215420643.davem@davemloft.net>
References: <6672379.kyQ5eFYq8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030824AbbKEB7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 20:59:40 -0500
In-Reply-To: <6672379.kyQ5eFYq8y@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 04 Nov 2015 00:55:13 +0300

> While the ring allocation is done by a single function, sh_eth_ring_init(),
> the ring deallocation was split into two functions (almost always called
> one after the other) for no good reason. Merge  sh_eth_free_dma_buffer()
> into sh_eth_ring_free() which allows us  to save space not only on the
> direct calls  of the former function but also on the sh_eth_ring_init()'s
> simplified error path...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
