From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make struct napi_alloc_cache::skb_count unsigned
 int
Date: Sat, 19 Nov 2016 22:11:42 -0500 (EST)
Message-ID: <20161119.221142.1237956123536159486.davem@davemloft.net>
References: <20161119004756.GC1200@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbcKTDLo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:11:44 -0500
In-Reply-To: <20161119004756.GC1200@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 19 Nov 2016 03:47:56 +0300

> size_t is way too much for an integer not exceeding 64.
> 
> Space savings: 10 bytes!
> 
> 	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
> 	function                                     old     new   delta
> 	napi_consume_skb                             165     163      -2
> 	__kfree_skb_flush                             56      53      -3
> 	__kfree_skb_defer                             97      92      -5
> 	Total: Before=154865639, After=154865629, chg -0.00%
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next.
