From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*" and "foo * bar"
Date: Fri, 28 Mar 2014 11:17:04 +0100
Message-ID: <20140328101704.GD11063@order.stressinduktion.org>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com> <1395979624-8544-4-git-send-email-wangyufen@huawei.com> <1395980521.19009.8.camel@joe-AO722> <20140328.014012.963819707045886028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: joe@perches.com, wangyufen@huawei.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36957 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbaC1KRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 06:17:06 -0400
Content-Disposition: inline
In-Reply-To: <20140328.014012.963819707045886028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 01:40:12AM -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 27 Mar 2014 21:22:01 -0700
> 
> > On Fri, 2014-03-28 at 12:07 +0800, Wangyufen wrote:
> > []
> >> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > []
> >> @@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
> >>  	       addr[fn_bit >> 5];
> >>  }
> > 
> > Perhaps all the __inline__ uses could be changed to inline too.
> 
> Or rather, deleted completely, this is a *.c file after all.

Smart-arsing:

Removing inline keyword makes the function visible to tracing if
it didn't get inlined. I think this is a nice side-effect because debug
kernels are often compiled with less aggressive inlining options
(readable asm kconfig option).
