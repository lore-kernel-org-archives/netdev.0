From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] netprio_cgroup.h: dont include module.h from other
 includes
Date: Wed, 25 Jan 2012 06:59:21 -0500
Message-ID: <20120125115921.GA26366@hmsreliant.think-freely.org>
References: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jdb@comx.dk,
	eric.dumazet@gmail.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50003 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2AYL7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 06:59:37 -0500
Content-Disposition: inline
In-Reply-To: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 04:33:19PM -0500, Paul Gortmaker wrote:
> A considerable effort was invested in wiping out module.h
> from being present in all the other standard includes.  This
> one leaked back in, but once again isn't strictly necessary,
> so remove it.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> ---
> 
> [x86-64 modconfig, yesconfig and ppc64 defconfig all build OK]
> 
> diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
> index e503b87..7b2d431 100644
> --- a/include/net/netprio_cgroup.h
> +++ b/include/net/netprio_cgroup.h
> @@ -13,7 +13,6 @@
>  
>  #ifndef _NETPRIO_CGROUP_H
>  #define _NETPRIO_CGROUP_H
> -#include <linux/module.h>
>  #include <linux/cgroup.h>
>  #include <linux/hardirq.h>
>  #include <linux/rcupdate.h>
> -- 
> 1.7.7.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
