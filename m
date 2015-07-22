From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: suppress a division by zero warning
Date: Tue, 21 Jul 2015 22:13:29 -0700 (PDT)
Message-ID: <20150721.221329.589521534912591124.davem@davemloft.net>
References: <1437541320.16824.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbGVFNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:13:42 -0400
In-Reply-To: <1437541320.16824.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Jul 2015 07:02:00 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrew Morton reported following warning on one ARM build
> with gcc-4.4 :
> 
> net/ipv4/inet_hashtables.c: In function 'inet_ehash_locks_alloc':
> net/ipv4/inet_hashtables.c:617: warning: division by zero
> 
> Even guarded with a test on sizeof(spinlock_t), compiler does not
> like current construct on a !CONFIG_SMP build.
> 
> Remove the warning by using a temporary variable.
> 
> Fixes: 095dc8e0c368 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
