From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use hash_32() in tcp_metrics
Date: Fri, 20 Jul 2012 11:00:48 -0700 (PDT)
Message-ID: <20120720.110048.55798397681108415.davem@davemloft.net>
References: <1342774954.2626.6290.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab2GTSAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:00:49 -0400
In-Reply-To: <1342774954.2626.6290.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jul 2012 11:02:34 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix a missing roundup_pow_of_two(), since tcpmhash_entries is not
> guaranteed to be a power of two.
> 
> Uses hash_32() instead of custom hash.
> 
> tcpmhash_entries should be an unsigned int.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
