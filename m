From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] flowcache: make flow_key_size() return
 "unsigned int"
Date: Mon, 03 Apr 2017 19:05:07 -0700 (PDT)
Message-ID: <20170403.190507.542513429419021746.davem@davemloft.net>
References: <20170402215150.GA8938@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdDDCFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:05:09 -0400
In-Reply-To: <20170402215150.GA8938@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Apr 2017 00:51:50 +0300

> Flow keys aren't 4GB+ numbers so 64-bit arithmetic is excessive.
> 
> Space savings (I'm not sure what CSWTCH is):
> 
> 	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-48 (-48)
> 	function                                     old     new   delta
> 	flow_cache_lookup                           1163    1159      -4
> 	CSWTCH                                     75997   75953     -44
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
