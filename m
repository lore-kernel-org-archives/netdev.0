From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunrpc: set SOCK_FASYNC
Date: Fri, 13 May 2016 01:46:18 -0400 (EDT)
Message-ID: <20160513.014618.367967738394775604.davem@davemloft.net>
References: <20160502191229.GA1946@nanopsycho.orion>
	<1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463114499.23934.179.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, edumazet@google.com, netdev@vger.kernel.org,
	ying.huang@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbcEMFqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 01:46:23 -0400
In-Reply-To: <1463114499.23934.179.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 May 2016 21:41:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sunrpc is using SOCKWQ_ASYNC_NOSPACE without setting SOCK_FASYNC,
> so the recent optimizations done in sk_set_bit() and sk_clear_bit()
> broke it.
> 
> There is still the risk that a subsequent sock_fasync() call
> would clear SOCK_FASYNC, but sunrpc does not use this yet.
> 
> Fixes: 9317bb69824e ("net: SOCKWQ_ASYNC_NOSPACE optimizations")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> Reported-by: Huang, Ying <ying.huang@intel.com>
> Tested-by: Jiri Pirko <jiri@resnulli.us>
> Tested-by: Huang, Ying <ying.huang@intel.com>

Applied, thanks.
