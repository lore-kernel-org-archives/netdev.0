From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove sysctl jiffies conversion on
 gc_elasticity and min_adv_ms
Date: Sat, 14 Aug 2010 22:43:00 -0700 (PDT)
Message-ID: <20100814.224300.212702574.davem@davemloft.net>
References: <alpine.LFD.2.00.1008131249060.27872@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mzhang@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459Ab0HOFmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 01:42:42 -0400
In-Reply-To: <alpine.LFD.2.00.1008131249060.27872@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Min Zhang <mzhang@mvista.com>
Date: Fri, 13 Aug 2010 12:50:37 -0700 (PDT)

> ipv6: remove sysctl jiffies conversion on gc_elasticity and
> min_adv_mss
> 
> sysctl output ipv6 gc_elasticity and min_adv_mss as values divided by
> HZ. However, they are not in unit of jiffies, since ip6_rt_min_advmss
> refers to packet size and ip6_rt_fc_elasticity is used as scaler as in
> expire>>ip6_rt_gc_elasticity, so replace the jiffies conversion
> handler will regular handler for them.
> 
> This has impact on scripts that are currently working assuming the
> divide by HZ, will yield different results with this patch in place.
> 
> Signed-off-by: Min Zhang <mzhang@mvista.com>

Applied, thank you.
