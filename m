From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6 fib: Make rt6_info{} more cache-line
 aware.
Date: Thu, 01 Apr 2010 18:45:08 -0700 (PDT)
Message-ID: <20100401.184508.144448196.davem@davemloft.net>
References: <4BB45836.2060104@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759143Ab0DBBpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:45:07 -0400
In-Reply-To: <4BB45836.2060104@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 01 Apr 2010 17:24:22 +0900

> The head element of rt6_info{} is dst_entry{}, and
> IPv6 specific elements follow.
> 
> Because elements at the end of dst_entry{} are frequently
> updated, it is not good to put frequently-used static
> elements, such as rt6i_idev, rt6i_dst or rt6i_flags in the
> same cache line.
> 
> On the other hand, fib6_table, rt6i_node or rt6i_gateway are
> rarely used, so it is okay to stay in the same cache line.
> 
> Let's rearrange rt6_info{}.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
