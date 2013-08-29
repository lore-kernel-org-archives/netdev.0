From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: sendto/hdrincl: don't use destination address
 found in header
Date: Thu, 29 Aug 2013 15:59:46 -0400 (EDT)
Message-ID: <20130829.155946.2289111569129635752.davem@davemloft.net>
References: <alpine.DEB.2.02.1308271153040.2079@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chris.clark@alcatel-lucent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab3H2T7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:59:47 -0400
In-Reply-To: <alpine.DEB.2.02.1308271153040.2079@optio.utah.ind.alcatel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Clark <chris.clark@alcatel-lucent.com>
Date: Tue, 27 Aug 2013 12:02:15 -0600 (MDT)

> 
> ipv4: raw_sendmsg: don't use header's destination address
> 
> A sendto() regression was bisected and found to start with commit
> f8126f1d5136be1 (ipv4: Adjust semantics of rt->rt_gateway.)
> 
> The problem is that it tries to ARP-lookup the constructed packet's
> destination address rather than the explicitly provided address.
> 
> Fix this using FLOWI_FLAG_KNOWN_NH so that given nexthop is used.
> 
> cf. commit 2ad5b9e4bd314fc685086b99e90e5de3bc59e26b
> 
> Reported-by: Chris Clark <chris.clark@alcatel-lucent.com>
> Bisected-by: Chris Clark <chris.clark@alcatel-lucent.com>
> Tested-by: Chris Clark <chris.clark@alcatel-lucent.com>
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Chris Clark <chris.clark@alcatel-lucent.com>

Applied and queued up for -stable, thanks.
