From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: neigh: make ->hh_len 32-bit
Date: Wed, 12 Apr 2017 13:59:33 -0400 (EDT)
Message-ID: <20170412.135933.1467285428701876235.davem@davemloft.net>
References: <20170410081117.GB24514@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754807AbdDLR7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:59:35 -0400
In-Reply-To: <20170410081117.GB24514@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 10 Apr 2017 11:11:17 +0300

> Using 16-bit ->hh_len doesn't save any memory, save some .text instead:
> 
> 	add/remove: 0/0 grow/shrink: 1/6 up/down: 2/-19 (-17)
> 	function                                     old     new   delta
> 	neigh_update                                2312    2314      +2
> 	fwnet_header_cache                           199     197      -2
> 	eth_header_cache                             101      99      -2
> 	ip6_finish_output2                          2371    2368      -3
> 	vrf_finish_output6                          1522    1518      -4
> 	vrf_finish_output                           1413    1409      -4
> 	ip_finish_output2                           1627    1623      -4
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
