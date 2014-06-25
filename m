From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: reduce TLB pressure for listeners
Date: Wed, 25 Jun 2014 16:37:42 -0700 (PDT)
Message-ID: <20140625.163742.2006962270899373416.davem@davemloft.net>
References: <1403613168.3796.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbaFYXhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:37:43 -0400
In-Reply-To: <1403613168.3796.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jun 2014 05:32:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems overkill to use vmalloc() for typical listeners with less than
> 2048 hash buckets. Try kmalloc() and fallback to vmalloc() to reduce TLB
> pressure.
> 
> Use kvfree() helper as it is now available.
> Use ilog2() instead of a loop.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
