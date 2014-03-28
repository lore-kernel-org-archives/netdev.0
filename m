From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix get_timewait4_sock() delay computation on
 64bit
Date: Fri, 28 Mar 2014 16:43:41 -0400 (EDT)
Message-ID: <20140328.164341.1721397857839483926.davem@davemloft.net>
References: <1395929959.12610.288.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbaC1Unn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:43:43 -0400
In-Reply-To: <1395929959.12610.288.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Mar 2014 07:19:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems I missed one change in get_timewait4_sock() to compute
> the remaining time before deletion of IPV4 timewait socket.
> 
> This could result in wrong output in /proc/net/tcp for tm->when field.
> 
> Fixes: 96f817fedec4 ("tcp: shrink tcp6_timewait_sock by one cache line")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
