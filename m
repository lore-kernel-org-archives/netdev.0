From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: restore correct limit
Date: Tue, 10 Apr 2012 14:42:18 -0400 (EDT)
Message-ID: <20120410.144218.1950459716672303437.davem@davemloft.net>
References: <4F840B99.8040409@redhat.com>
	<1334054436.3126.80.camel@edumazet-glaptop>
	<1334055402.3126.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, monstr@monstr.eu, netdev@vger.kernel.org,
	john.williams@petalogix.com, glommer@parallels.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab2DJSm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:42:29 -0400
In-Reply-To: <1334055402.3126.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Apr 2012 12:56:42 +0200

> Commit c43b874d5d714f (tcp: properly initialize tcp memory limits) tried
> to fix a regression added in commits 4acb4190 & 3dc43e3,
> but still get it wrong.
> 
> Result is machines with low amount of memory have too small tcp_rmem[2]
> value and slow tcp receives : Per socket limit being 1/1024 of memory
> instead of 1/128 in old kernels, so rcv window is capped to small
> values.
> 
> Fix this to match comment and previous behavior.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Glauber Costa <glommer@parallels.com>

Applied and queued up for -stable, thanks Eric.
