From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] ipv6: prevent fib6_run_gc() contention
Date: Thu, 01 Aug 2013 14:18:54 -0700 (PDT)
Message-ID: <20130801.141854.195027071785270218.davem@davemloft.net>
References: <cover.1375343204.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab3HAVSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 17:18:55 -0400
In-Reply-To: <cover.1375343204.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu,  1 Aug 2013 10:04:04 +0200 (CEST)

> On a high-traffic router with many processors and many IPv6 dst entries,
> soft lockup in fib6_run_gc() can occur when number of entries reaches
> gc_thresh. Prevent this by not waiting for the lock if garbage collector
> is already running as we would only run it again as soon as it finished.
> 
> v2: as suggested by Eric Dumazet, move update of ip6_rt_last_gc into
>     fib6_run_gc() so that it reflects every run of garbage collector
>     rather than only those via ip6_dst_gc()

Applied, thanks.
