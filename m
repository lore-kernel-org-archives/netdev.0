From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove sysctl jiffies conversion on
 gc_elasticity and min_adv_ms
Date: Sat, 24 Jul 2010 21:03:05 -0700 (PDT)
Message-ID: <20100724.210305.59676046.davem@davemloft.net>
References: <4C48BA82.6020904@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mzhang@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750716Ab0GYECt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 00:02:49 -0400
In-Reply-To: <4C48BA82.6020904@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Min Zhang <mzhang@mvista.com>
Date: Thu, 22 Jul 2010 14:39:14 -0700

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

Your email client corrupted your patch, turning tab characters into
spaces.  This makes your patch unusable.

Please resubmit this patch properly so that I can use it.

Thanks.
