From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Tue, 22 Jun 2010 10:25:08 -0700 (PDT)
Message-ID: <20100622.102508.229763509.davem@davemloft.net>
References: <20100614.231412.39191304.davem@davemloft.net>
	<1276596856.2541.84.camel@edumazet-laptop>
	<1276598376.2541.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, npiggin@suse.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756012Ab0FVRY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:24:56 -0400
In-Reply-To: <1276598376.2541.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jun 2010 12:39:36 +0200

> Note : should be applied after "net: Introduce 
> u64_stats_sync infrastructure", if accepted.
> 
> 
> Thanks
> 
> [PATCH net-next-2.6] bridge: 64bit rx/tx counters
> 
> Use u64_stats_sync infrastructure to provide 64bit rx/tx 
> counters even on 32bit hosts.
> 
> It is safe to use a single u64_stats_sync for rx and tx,
> because BH is disabled on both, and we use per_cpu data.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
