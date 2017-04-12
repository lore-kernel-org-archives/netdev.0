From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make struct net_device::min_header_len 8-bit
Date: Wed, 12 Apr 2017 13:59:40 -0400 (EDT)
Message-ID: <20170412.135940.1431947186410769270.davem@davemloft.net>
References: <20170410082526.GC24514@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754614AbdDLR7m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:59:42 -0400
In-Reply-To: <20170410082526.GC24514@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 10 Apr 2017 11:25:26 +0300

> This field is never big enough to warrant 16-bitness.
> 
> 8-bit accesses enjoy shorted encoding on i386/x86_64 than 16-bit
> accesses:
> 
> 	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-10 (-10)
> 	function                                     old     new   delta
> 	loopback_setup                               169     164      -5
> 	ether_setup                                  148     143      -5
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
