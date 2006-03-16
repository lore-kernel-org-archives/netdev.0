From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Cleanups for net/ipv6/addrconf.c (kzalloc, early
 exit) v2
Date: Thu, 16 Mar 2006 00:20:04 -0800 (PST)
Message-ID: <20060316.002004.97779505.davem@davemloft.net>
References: <20060212.021103.76157181.yoshfuji@linux-ipv6.org>
	<20060310.030258.55767431.davem@davemloft.net>
	<200603102334.27590.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752245AbWCPIUc@vger.kernel.org>
To: ioe-lkml@rameria.de
In-Reply-To: <200603102334.27590.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <ioe-lkml@rameria.de>
Date: Fri, 10 Mar 2006 23:34:26 +0100

> Here are some possible (and trivial) cleanups.
> - use kzalloc() where possible
> - invert allocation failure test like
>   if (object) {
>         /* Rest of function here */
>   }
>   to
> 
>   if (object == NULL)
>         return NULL;
> 
>   /* Rest of function here */
> 
> Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks a lot Ingo.
