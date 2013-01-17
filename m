From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] IPv6: rt->n (neighbour in rt6_info)
 removal (TAKE 3)
Date: Thu, 17 Jan 2013 17:53:16 -0500 (EST)
Message-ID: <20130117.175316.2254554394400383765.davem@davemloft.net>
References: <50F837D5.4020505@linux-ipv6.org>
	<20130117.153753.1608817353719202851.davem@davemloft.net>
	<20130117224222.GA29674@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab3AQWxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:53:17 -0500
In-Reply-To: <20130117224222.GA29674@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 17 Jan 2013 17:42:22 -0500

> On Thu, Jan 17, 2013 at 03:37:53PM -0500, David Miller wrote:
>  > From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>  > Date: Fri, 18 Jan 2013 02:41:41 +0900
>  > 
>  > > This is "TAKE 3" of neighbour removal from rt6_info.
>  > > 
>  > > 2->3:
>  > > - Removed "icmp6_dst_alloc() removal" patch.
>  > >   This is nothing to do with this series.
>  > > - Removed several unused variables, ifdefs, BUG_ONs.
>  > > - Handled several comments from Cong Wang.
>  > > - Reordered.
>  > 
>  > This series is almost perfect, great work.
> 
> I guess if this is going in soon, the ip6 rt->n related oops I reported
> this morning is moot ? (unless anyone cares about fixing it for older kernels)

I wouldn't say it's moot for older kernels, that's for sure.
