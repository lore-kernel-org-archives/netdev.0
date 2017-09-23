From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use 32-bit arithmetic while allocating net device
Date: Fri, 22 Sep 2017 21:26:15 -0700 (PDT)
Message-ID: <20170922.212615.331848619211614093.davem@davemloft.net>
References: <20170921203329.GA13550@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdIWE0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 00:26:25 -0400
In-Reply-To: <20170921203329.GA13550@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 21 Sep 2017 23:33:29 +0300

> Private part of allocation is never big enough to warrant size_t.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
> 	function                                     old     new   delta
> 	alloc_netdev_mqs                            1120    1110     -10
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next.
