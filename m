From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCN net-next-2.6] drivers/net: use vzalloc()
Date: Tue, 30 Nov 2010 11:52:10 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1011301145470.10832@jbrandeb-desk1.amr.corp.intel.com>
References: <1290420906.2811.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12009 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab0K3TwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 14:52:11 -0500
In-Reply-To: <1290420906.2811.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 22 Nov 2010, Eric Dumazet wrote:

> Use vzalloc() and vzalloc_node() in net drivers
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> People, I hope you dont mind if I make a single patch, and dont Cc all
> maintainers, for such trivial change.
>  drivers/net/e1000/e1000_main.c       |    6 +---
>  drivers/net/e1000e/netdev.c          |    6 +---
>  drivers/net/igb/igb_main.c           |    6 +---
>  drivers/net/igbvf/netdev.c           |    6 +---
>  drivers/net/ixgb/ixgb_main.c         |    6 +---
>  drivers/net/ixgbe/ixgbe_main.c       |   10 +++-----
>  drivers/net/ixgbevf/ixgbevf_main.c   |    6 +---

Thanks Eric, intel parts look good.

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

