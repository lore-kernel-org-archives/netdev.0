From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: use napi_complete_done()
Date: Fri, 06 Mar 2015 00:20:42 -0500 (EST)
Message-ID: <20150306.002042.934374176574379322.davem@davemloft.net>
References: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbbCFFUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:45 -0500
In-Reply-To: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Mar 2015 10:41:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Using napi_complete_done() instead of napi_complete() allows
> us to use /sys/class/net/ethX/gro_flush_timeout
> 
> GRO layer can aggregate more packets if the flush is delayed a bit,
> without having to set too big coalescing parameters that impact
> latencies.
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
