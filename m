From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] flowcache: make flow_cache_hash_size() return
 "unsigned int"
Date: Mon, 03 Apr 2017 19:05:14 -0700 (PDT)
Message-ID: <20170403.190514.1444108071119456432.davem@davemloft.net>
References: <20170402215150.GA8938@avx2>
        <20170402215229.GB8938@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbdDDCFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:05:16 -0400
In-Reply-To: <20170402215229.GB8938@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Apr 2017 00:52:29 +0300

> Hash size can't negative so "unsigned int" is logically correct.
> 
> Propagate "unsigned int" to loop counters.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 2/2 up/down: 6/-18 (-12)
> 	function                                     old     new   delta
> 	flow_cache_flush_tasklet                     362     365      +3
> 	__flow_cache_shrink                          333     336      +3
> 	flow_cache_cpu_up_prep                       178     171      -7
> 	flow_cache_lookup                           1159    1148     -11
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
