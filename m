From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make struct net_device::tx_queue_len
 unsigned int
Date: Thu, 18 May 2017 10:20:01 -0400 (EDT)
Message-ID: <20170518.102001.715764939763640042.davem@davemloft.net>
References: <20170517103044.GA28488@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755323AbdEROUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:20:03 -0400
In-Reply-To: <20170517103044.GA28488@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 17 May 2017 13:30:44 +0300

> 4 billion packet queue is something unthinkable so use 32-bit value
> for now.
> 
> Space savings on x86_64:
> 
> 	add/remove: 0/0 grow/shrink: 3/70 up/down: 16/-131 (-115)
> 	function                                     old     new   delta
> 	change_tx_queue_len                           94     108     +14
> 	qdisc_create                                1176    1177      +1
> 	alloc_netdev_mqs                            1124    1125      +1
> 	xenvif_alloc                                 533     532      -1
> 	x25_asy_setup                                167     166      -1
> 			...
> 	tun_queue_resize                             945     940      -5
> 	pfifo_fast_enqueue                           167     162      -5
> 	qfq_init_qdisc                               168     158     -10
> 	tap_queue_resize                             810     799     -11
> 	transmit                                     719     698     -21
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
