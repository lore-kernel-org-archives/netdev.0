From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable] ipv4: avoid passing NULL to inet_putpeer() in
 icmpv4_xrlim_allow()
Date: Fri, 07 Dec 2012 12:14:29 -0500 (EST)
Message-ID: <20121207.121429.1891539902462905192.davem@davemloft.net>
References: <1411074275.5265862.1354894974886.JavaMail.root@redhat.com>
	<1443466888.5267673.1354895200559.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: caiqian@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423124Ab2LGROe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:14:34 -0500
In-Reply-To: <1443466888.5267673.1354895200559.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: CAI Qian <caiqian@redhat.com>
Date: Fri, 7 Dec 2012 10:46:40 -0500 (EST)

> David, this patch looks applicable for the stable releases.
> 
> From Neal Cardwell <ncardwell@google.com>
> 
> inet_getpeer_v4() can return NULL under OOM conditions, and while
> inet_peer_xrlim_allow() is OK with a NULL peer, inet_putpeer() will
> crash.
> 
> This code path now uses the same idiom as the others from:
> 1d861aa4b3fb08822055345f480850205ffe6170 ("inet: Minimize use of
> cached route inetpeer.").
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Upstream-ID: e1a676424c290b1c8d757e3860170ac7ecd89af4
> Stable-trees: 3.6.x
> Signed-off-by: CAI Qian <caiqian@redhat.com>

Please stop submitting networking -stable changes.
