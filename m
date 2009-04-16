From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ixgbe: missing parentheses
Date: Thu, 16 Apr 2009 14:16:10 -0700
Message-ID: <20090416141610.ad8b9909.akpm@linux-foundation.org>
References: <49E79D7C.2080200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38155 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbZDPVTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:19:09 -0400
In-Reply-To: <49E79D7C.2080200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Thu, 16 Apr 2009 23:05:00 +0200
Roel Kluin <roel.kluin@gmail.com> wrote:

> `!' has a higher precedence than `&'
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index febde45..49a9037 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3946,7 +3946,7 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
>  	}
>  	hw->mac.ops.setup_sfp(hw);
>  
> -	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
> +	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
>  		/* This will also work for DA Twinax connections */
>  		schedule_work(&adapter->multispeed_fiber_task);
>  	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;

This is fixed in linux-next, but hasn't been pushed to Linus yet.
